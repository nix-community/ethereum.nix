{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mdDoc types mkOption mkEnableOption mkIf mkBefore mkAfter mkMerge filterAttrs attrValues forEach mapAttrs;
  inherit (lib) flatten nameValuePair concatMapStrings listToAttrs;
  inherit (builtins) concatStringsSep attrNames map;

  cfg = config.services.ethereum.backup;

  excludeFile =
    # Write each exclude pattern to a new line
    pkgs.writeText "excludefile" (concatMapStrings (s: s + "\n") cfg.borg.exclude);

  gethJq = pkgs.writeTextFile {
    name = "convert.jq";
    text = ''
      def to_i(base):
        explode
        | reverse
        | map(if . > 96  then . - 87 else . - 48 end)  # "a" ~ 97 => 10 ~ 87
        | reduce .[] as $c
            # state: [power, ans]
            ([1,0]; (.[0] * base) as $b | [$b, .[1] + (.[0] * $c)])
        | .[1];

      .result | {hash,stateRoot,number}  + {"height": (.number[2:] | to_i(16)) }
    '';
  };

  metadataScript = pkgs.writeShellScript "metadata" ''
    set -euo pipefail

    SERVICE_NAME=$1

    PID=$(systemctl show --property MainPID $SERVICE_NAME | cut -d'=' -f2)
    if [ $PID -eq 0 ]; then
        echo "$SERVICE_NAME is not running, exiting"
        exit 1
    fi

    # source the same environment as the service
    eval $(strings /proc/$PID/environ | grep -E '^(WEB3_*|GRPC_*|STATE_DIRECTORY)')

    case $SERVICE_NAME in

        geth-*)
            curl -s -X POST \
                -H 'Content-Type: application/json' \
                -d '{"jsonrpc":"2.0","id":1,"method":"eth_getBlockByNumber","params":["latest",false]}' \
                http://$WEB3_HTTP_HOST:$WEB3_HTTP_PORT \
                | jq -f ${gethJq} > $STATE_DIRECTORY/.metadata.json
            ;;

        prysm-beacon-*)
            curl -s http://$GRPC_GATEWAY_HOST:$GRPC_GATEWAY_PORT/eth/v1/node/syncing \
                | jq '.data + { "height": (.data.head_slot | tonumber) }' > $STATE_DIRECTORY/.metadata.json
            ;;

        *)
            echo "Unknown client type: $SERVICE_NAME"
            exit 1
            ;;
    esac
  '';

  setupVolumeScript = pkgs.writeShellScript "setup-volume" ''
    set -euo pipefail

    # determine the private path to the volume mount
    SERVICE_NAME=$(basename $STATE_DIRECTORY)
    VOLUME_DIR=/var/lib/private/$SERVICE_NAME

    # ensure cowdata is disabled
    chattr +C $VOLUME_DIR
  '';

  snapshotVolumeScript = pkgs.writeShellScript "snapshot-volume" ''
    set -euo pipefail

    # check it was a clean shutdown before snapshotting
    if [ $EXIT_STATUS -ne 0 ]; then
        echo "Unclean shutdown detected: $EXIT_CODE, skipping snapshot"
        exit 1
    fi

    # determine the private path to the volume mount
    SERVICE_NAME=$(basename $STATE_DIRECTORY)
    VOLUME_DIR=/var/lib/private/$SERVICE_NAME

    # metadata path
    METADATA_JSON="$STATE_DIRECTORY/.metadata.json"

    # check if the metadata file exists
    if [ ! -f $METADATA_JSON ]; then
        echo "Could not locate $METADATA_JSON, skipping snapshot"
        exit 1
    fi

    # ensure the metadata file is recent
    NOW_SECONDS=$(date +%s)
    METADATA_SECONDS=$(date +%s -r $METADATA_JSON)
    METADATA_AGE=$((NOW_SECONDS - METADATA_SECONDS))

    if [ $METADATA_AGE -gt 30 ]; then
        echo "$METADATA_JSON is older than 30 seconds, skipping snapshot"
        exit 1
    fi

    # determine the chain height from the metadata
    HEIGHT=$(cat $METADATA_JSON | jq .height)

    if [ -z $\{HEIGHT+x} ]; then
        echo "Could not determine height from $METADATA_JSON, skipping snapshot";
        exit 1
    fi

    # ensure the base snapshot directory exists
    mkdir -p ${cfg.snapshotDirectory}/$SERVICE_NAME

    # check if the snapshot we are about to create already exists
    SNAPSHOT_DIR=${cfg.snapshotDirectory}/$SERVICE_NAME/$HEIGHT

    if [ -d $SNAPSHOT_DIR ]; then
      echo "Snapshot already exists: $SNAPSHOT_DIR, skipping snapshot"
      exit 0
    fi

    # create a readonly snapshot
    btrfs subvolume snapshot -r $VOLUME_DIR $SNAPSHOT_DIR
  '';

  mkMetadataService = name:
    nameValuePair "${name}-metadata" {
      description = "Captures metadata about ${name}";
      path = with pkgs; [
        curl
        jq
        binutils
      ];
      serviceConfig = {
        User = "root";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = "${metadataScript} ${name}";
      };
    };

  mkMetadataTimer = name:
    nameValuePair "${name}-metadata" {
      description = "Metadata timer for ${name}-metadata";
      wantedBy = ["timers.target"];
      timerConfig = {
        Persistent = true;
        OnCalendar = "*:*:0/10";
      };
      # wait for network
      after = ["network-online.target"];
    };

  addSnapshotToService = name:
    nameValuePair "${name}" {
      path = with pkgs; [
        btrfs-progs
        e2fsprogs
        jq
      ];
      serviceConfig = {
        ExecStartPre = mkBefore [
          "+${setupVolumeScript}"
        ];
        ExecStopPost = mkAfter [
          "+${snapshotVolumeScript}"
        ];
      };
    };

  backupScript = pkgs.writeShellScript "backup" ''
    set -euo pipefail
    echo "Running backup"

    export BORG_RSH="ssh -o StrictHostKeyChecking=no -i $CREDENTIALS_DIRECTORY/sshKey";

    SERVICE_NAMES=$@

    for SERVICE in $SERVICE_NAMES; do
        REPO="${cfg.borg.repo}/$SERVICE"

        if ! borg list $REPO > /dev/null; then
            echo "Creating repo: $REPO"
            borg init --encryption none $REPO
        fi
    done

    for SERVICE in $SERVICE_NAMES; do

        REPO="${cfg.borg.repo}/$SERVICE"

        # restart the service to create the snapshot
        echo "Restarting $SERVICE"
        systemctl restart "$SERVICE.service"

        echo "Backing up snapshots for $SERVICE"

        # reverse order ensures the greatest chain height first and reduces the bandwidth needed
        # to transfer earlier archives
        ARCHIVES=$(ls -r "$SNAPSHOT_DIR/$SERVICE")

        for ARCHIVE in $ARCHIVES; do
            if borg list $REPO::$ARCHIVE > /dev/null; then
                echo "Archive $REPO::$ARCHIVE already exists, skipping"
            else
                borg create -s --verbose \
                    --lock-wait ${builtins.toString cfg.borg.lockWait} \
                    --compression ${cfg.borg.compression} \
                    --exclude ${excludeFile} \
                    $REPO::$ARCHIVE \
                    $SNAPSHOT_DIR/$SERVICE/$ARCHIVE
            fi
        done
    done
  '';

  backupService = nameValuePair "ethereum-backup" {
    description = "Backup service for Ethereum clients";
    path = with pkgs; [
      borgbackup
      openssh
      systemd
    ];
    environment = {
      # suppress prompts
      BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
      SNAPSHOT_DIR = cfg.snapshotDirectory;
    };
    serviceConfig = {
      User = "root";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      ProtectSystem = "strict";
      PrivateTmp = true;
      StateDirectory = "ethereum-backup";
      LoadCredential = "sshKey:${cfg.borg.keyPath}";
      ExecStart = "${backupScript} ${builtins.concatStringsSep " " cfg.services}";
    };
  };

  backupTimer = nameValuePair "ethereum-backup" {
    description = "Timer for ethereum-backup";
    wantedBy = ["timers.target"];
    timerConfig = {
      Persistent = true;
      OnCalendar = cfg.schedule;
    };
    # wait for network
    after = ["network-online.target"];
  };
in {
  options = {
    # TODO validate the service has been configured for snapshotting

    services.ethereum.backup = {
      enable = mkEnableOption (mdDoc "Enable backup");

      services = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      snapshotDirectory = mkOption {
        type = lib.types.path;
        default = "/snapshots";
      };

      schedule = mkOption {
        type = types.str;
        description = mdDoc "Time interval for checking the snapshot directory and running a backup. Format is the same as systemd.time";
        default = "hourly";
        example = "daily";
      };

      borg = with lib; {
        repo = mkOption {
          type = types.str;
          description = lib.mdDoc "Remote or local repository to back up to.";
          example = "user@machine:/path/to/repo";
        };

        keyPath = mkOption {
          type = types.path;
          description = mdDoc "Path to a private key used for ssh";
        };

        lockWait = mkOption {
          type = types.int;
          description = mdDoc "Amount of time in seconds to wait when acquiring a repository lock";
          default = 3600;
        };

        exclude = mkOption {
          type = with types; listOf str;
          description = lib.mdDoc ''
            Exclude paths matching any of the given patterns. See
            {command}`borg help patterns` for pattern syntax.
          '';
          default = [
            "keystore"
            "geth/nodekey"
          ];
          example = [
            "/home/*/.cache"
            "/nix"
          ];
        };

        compression = mkOption {
          # "auto" is optional,
          # compression mode must be given,
          # compression level is optional
          type = types.strMatching "none|(auto,)?(lz4|zstd|zlib|lzma)(,[[:digit:]]{1,2})?";
          description = lib.mdDoc ''
            Compression method to use. Refer to
            {command}`borg help compression`
            for all available options.
          '';
          default = "lz4";
          example = "auto,lzma";
        };
      };
    };
  };

  config.systemd.services = listToAttrs (
    [backupService]
    ++ ((builtins.map mkMetadataService) cfg.services)
    ++ ((builtins.map addSnapshotToService) cfg.services)
  );

  config.systemd.timers = listToAttrs (
    [backupTimer]
    ++ ((builtins.map mkMetadataTimer) cfg.services)
  );
}
