{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mdDoc types mkOption mkEnableOption mkIf mkBefore mkAfter mkMerge filterAttrs attrValues forEach mapAttrs nameValuePair concatMapStrings;
  inherit (builtins) concatStringsSep attrNames map;

  cfg = config.services.ethereum.backup;
  snapshotCfg = config.services.ethereum.snapshot;

  snapshotDirectory = serviceName:
    if (snapshotCfg.enable == true) && (builtins.elem serviceName snapshotCfg.services)
    then config.services.ethereum.snapshot.snapshotDirectory
    else null;

  excludeFile =
    # Write each exclude pattern to a new line
    pkgs.writeText "excludefile" (concatMapStrings (s: s + "\n") cfg.borg.exclude);

  backupScript = pkgs.writeShellScript "backup" ''
    set -euo pipefail

    export BORG_RSH="ssh -o StrictHostKeyChecking=no -i $CREDENTIALS_DIRECTORY/sshKey";

    SERVICE_NAMES=$(ls $SNAPSHOT_DIR)

    for SERVICE in $SERVICE_NAMES; do
        REPO="${cfg.borg.repo}/$SERVICE"

        if ! borg list $REPO > /dev/null; then
            echo "Creating repo: $REPO"
            borg init --encryption none $REPO
        fi
    done

    for SERVICE in $SERVICE_NAMES; do

        REPO="${cfg.borg.repo}/$SERVICE"

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
in {
  options = {
    # TODO validate the service has been configured for snapshotting

    services.ethereum.backup = {
      enable = mkEnableOption (mdDoc "Enable backup");

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

      services = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  };

  config.systemd = mkIf cfg.enable {
    services = {
      "ethereum-backup" = {
        description = "Ethereum Backup";
        path = with pkgs; [
          borgbackup
          openssh
        ];
        serviceConfig = {
          # We need to be able to read everything in the snapshot directory
          # For now we're using root, I'm unsure if this could be tightened up
          User = "root";
          # Only run when no other process is using CPU or disk
          CPUSchedulingPolicy = "idle";
          IOSchedulingClass = "idle";
          ProtectSystem = "strict";
          PrivateTmp = true;
          ExecStart = backupScript;
          StateDirectory = "ethereum-backup";
          LoadCredential = "sshKey:${cfg.borg.keyPath}";
        };
        environment = {
          # suppress prompts
          BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
          SNAPSHOT_DIR = snapshotCfg.snapshotDirectory;
        };
      };
    };
    timers = {
      "ethereum-backup" = {
        description = "Ethereum Backup timer";
        wantedBy = ["timers.target"];
        timerConfig = {
          Persistent = true;
          OnCalendar = cfg.schedule;
        };
        # wait for network
        after = ["network-online.target"];
      };
    };
  };
}
