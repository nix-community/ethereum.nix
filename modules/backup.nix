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

    # we don't want to exit if the following commands fail as the process might be down as part of an update
    # and this unit was inflight at the time
    set +e

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

    if [ $? -eq 7 ]; then
        # curl provides this exit code if it couldn't connect to host
        echo "Could not connect to host"
        exit 0  # we exit nicely assuming that this is a transient error due to rollout of updates
    else
        >&2 echo "Failed to fetch metadata"
        exit 1
    fi
  '';

  setupVolumeScript = pkgs.writeShellScript "setup-volume" ''
    set -euo pipefail

    # determine the private path to the volume mount
    SERVICE_NAME=$(basename $STATE_DIRECTORY)
    VOLUME_DIR=/var/lib/private/$SERVICE_NAME

    if ! btrfs sub show $VOLUME_DIR > /dev/null; then
        echo "$VOLUME_DIR is not a btrfs subvolume, exiting"
        exit 0
    fi

    echo "Disabling copy on write"
    chattr -R +C $VOLUME_DIR
  '';

  chainHeightScript = pkgs.writeShellScript "chain-height" ''
    set -euo pipefail

    # metadata path
    METADATA_JSON=$1

    # check if the metadata file exists
    if [ ! -f $METADATA_JSON ]; then
        >&2 echo "Could not locate $METADATA_JSON, skipping snapshot"
        # client must have been in a bad state or it had not been able to initialise yet to a point
        # where it's RPC was active and returning so we indicate an error code
        exit 1
    fi

    # ensure the metadata file is recent
    NOW_SECONDS=$(date +%s)
    METADATA_SECONDS=$(date +%s -r $METADATA_JSON)
    METADATA_AGE=$((NOW_SECONDS - METADATA_SECONDS))

    if [ $METADATA_AGE -gt 30 ]; then
        >&2 echo "$METADATA_JSON is older than 30 seconds, skipping snapshot"
        # suspected failure in the metadata service, we can't be sure about the latest state of the client
        exit 1
    fi

    # determine the chain height from the metadata
    HEIGHT=$(cat $METADATA_JSON | jq .height)

    if [ -z $\{HEIGHT+x} ]; then
        >&2 echo "Could not determine height from $METADATA_JSON, skipping snapshot";
        # metadata is malformed
        exit 1
    fi
  '';

  # It's necessary to record the exit status so that we can safeguard against backing up unclean state directories
  # in the case of performing an in-situ backup. For btrfs snapshot based backups, the snapshot script already
  # performs an exit status check before snapshotting.

  clearExitStatusScript = pkgs.writeShellScript "clear-exit-status" ''
    rm -r $STATE_DIRECTORY/.exit-status
  '';

  recordExitStatusScript = pkgs.writeShellScript "record-exit-status" ''
    echo $EXIT_STATUS > $STATE_DIRECTORY/.exit-status
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

    # check if the volume is in fact a btrfs subvolume
    if ! btrfs sub show $VOLUME_DIR > /dev/null; then
        echo "$VOLUME_DIR is not a btrfs subvolume, skipping snapshot"
        exit 0  # clean exit as this hook will be registered against every service
    fi

    # determine chain height from metadata
    METADATA_JSON="$STATE_DIRECTORY/.metadata.json"
    HEIGHT=$(${chainHeightScript} $METADATA_JSON)

    if [ -z $\{HEIGHT+x} ]; then
        >&2 echo "Could not determine height from $METADATA_JSON, skipping snapshot";
        # metadata is malformed
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
      wantedBy = [
        "timers.target"
        # ensure the timer is started when the main service is started
        "${name}.service"
      ];
      # ensures this service is stopped if the main service is stopped
      bindsTo = ["${name}.service"];
      timerConfig = {
        Persistent = true;
        OnCalendar = "*:*:0/10"; # triggers every 10 seconds
      };
    };

  instrumentClientService = name:
    nameValuePair "${name}" {
      path = with pkgs; [
        btrfs-progs
        e2fsprogs
        jq
      ];
      serviceConfig = {
        ExecStartPre = mkBefore [
          clearExitStatusScript
          "+${setupVolumeScript}"
        ];
        ExecStopPost = mkAfter [
          recordExitStatusScript
          "+${snapshotVolumeScript}"
        ];
      };
    };

  backupScript = pkgs.writeShellScript "backup" ''
    set -euo pipefail

    export BORG_RSH="ssh -o StrictHostKeyChecking=no -i $CREDENTIALS_DIRECTORY/sshKey";

    SERVICE_NAMES=$@
    echo "Running backup for the following services: $SERVICE_NAMES"

    # first we ensure there is a borg repo for each configured service

    for SERVICE_NAME in $SERVICE_NAMES; do
        REPO="${cfg.borg.repo}/$SERVICE_NAME"

        if ! borg list $REPO > /dev/null; then
            echo "Creating repo: $REPO"
            borg init --encryption none $REPO
        fi
    done

    # next we go on a per-service basis:
    #
    #   - if the state directory is a btrfs subvolume, we restart the service to generate the snapshot and then backup
    #   - if the state directory is not a btrfs subvolume, we stop the service, perform the backup and then start the
    #     service again

    for SERVICE_NAME in $SERVICE_NAMES; do

        REPO="${cfg.borg.repo}/$SERVICE_NAME"
        STATE_DIRECTORY=/var/lib/private/$SERVICE_NAME

        if btrfs sub show $STATE_DIRECTORY > /dev/null; then

            echo "$STATE_DIRECTORY is a btrfs subvolume"

            # restart the service to create the snapshot
            echo "Restarting $SERVICE_NAME"
            systemctl restart "$SERVICE_NAME.service"

            echo "Backing up snapshots for $SERVICE_NAME"

            # reverse order ensures the greatest chain height first and reduces the bandwidth needed
            # to transfer earlier archives
            ARCHIVES=$(ls -r "$SNAPSHOT_DIR/$SERVICE_NAME")

            for ARCHIVE in $ARCHIVES; do
                if borg list $REPO::$ARCHIVE > /dev/null; then
                    echo "Archive $REPO::$ARCHIVE already exists, skipping"
                else
                    borg create -s --verbose \
                        --lock-wait ${builtins.toString cfg.borg.lockWait} \
                        --compression ${cfg.borg.compression} \
                        --exclude ${excludeFile} \
                        $REPO::$ARCHIVE \
                        $SNAPSHOT_DIR/$SERVICE_NAME/$ARCHIVE
                fi
            done

        else
            echo "$STATE_DIRECTORY is not a btrfs subvolume, performing in-situ backup"

            # stop the service
            echo "Stopping $SERVICE_NAME"
            systemctl stop "$SERVICE_NAME.service"

            # check that the process stopped cleanly
            EXIT_STATUS=$(cat $STATE_DIRECTORY/.exit-status)

            if [ $EXIT_STATUS -ne 0 ];
                >&2 echo "Unclean shutdown detected, exit status: $EXIT_STATUS. Skipping backup"
            then
                # determine chain height from metadata
                METADATA_JSON="$STATE_DIRECTORY/.metadata.json"
                HEIGHT=$(${chainHeightScript} $METADATA_JSON)

                if [ -z $\{HEIGHT+x} ]; then
                    >&2 echo "Could not determine height from $METADATA_JSON, skipping backup";
                else
                    ARCHIVE=$HEIGHT
                    if borg list $REPO::$HEIGHT > /dev/null; then
                        echo "Archive $REPO::$ARCHIVE already exists, skipping"
                    else
                        borg create -s --verbose \
                            --lock-wait ${builtins.toString cfg.borg.lockWait} \
                            --compression ${cfg.borg.compression} \
                            --exclude ${excludeFile} \
                            $REPO::$ARCHIVE \
                            $STATE_DIRECTORY
                    fi
                fi
            fi

            # start the service again
            systemctl start "$SERVICE_NAME.service"
        fi
    done
  '';

  backupService = nameValuePair "ethereum-backup" {
    description = "Backup service for Ethereum clients";
    path = with pkgs; [
      borgbackup
      btrfs-progs
      jq
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
    ++ ((builtins.map instrumentClientService) cfg.services)
  );

  config.systemd.timers = listToAttrs (
    [backupTimer]
    ++ ((builtins.map mkMetadataTimer) cfg.services)
  );
}
