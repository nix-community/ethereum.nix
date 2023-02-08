{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mdDoc types mkOption mkEnableOption mkIf mkBefore mkAfter mkMerge filterAttrs attrValues forEach mapAttrs;
  inherit (builtins) concatStringsSep attrNames map;

  cfg = config.services.ethereum.snapshot;

  # TODO remove hardcoding of /var/lib/private in paths below

  startPre = pkgs.writeShellScript "setup-volume" ''
    set -euo pipefail

    # determing the private path to the volume mount
    SERVICE_NAME=$(basename $STATE_DIRECTORY)
    VOLUME_DIR=/var/lib/private/$SERVICE_NAME

    # ensure cowdata is disabled
    chattr +C $VOLUME_DIR
  '';

  snapshotVolume = pkgs.writeShellScript "snapshot-volume" ''
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
    METADATA_JSON="$STATE_DIRECTORY/snapshot.json"

    if [ -f $METADATA_JSON ]; then
        SNAPSHOT_DIR=$(cat $METADATA_JSON | jq '.Number')
    else
        # ISO 8601 date
        SNAPSHOT_DIR=$(date +"%Y-%m-%dT%H:%M:%S%:z")
    fi

    # ensure the base directory exists
    mkdir -p ${cfg.snapshotDirectory}/$SERVICE_NAME

    # create a readonly snapshot
    btrfs subvolume snapshot -r $VOLUME_DIR ${cfg.snapshotDirectory}/$SERVICE_NAME/$SNAPSHOT_DIR
  '';

  prune = pkgs.writeShellScript "prune" ''
    set -euo pipefail

    BTRFS=${pkgs.btrfs-progs}/bin/btrfs

    # determine the private path to the volume mount
    SERVICE_NAME=$(basename $STATE_DIRECTORY)
    SERVICE_SNAPSHOT_DIR=${cfg.snapshotDirectory}/$SERVICE_NAME

    # delete any subvolumes older than $RETENTION days
    find $SERVICE_SNAPSHOT_DIR -mindepth 1 -maxdepth 1 -type d -ctime +$RETENTION -exec $BTRFS sub delete {} \;
  '';
in {
  options = {
    services.ethereum.snapshot = {
      enable = mkEnableOption (mdDoc "Enable snapshotting");

      services = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      interval = mkOption {
        type = types.str;
        description = mdDoc "Time interval for restarting the configured service, thereby generating a snapshot";
        default = "1d";
        example = "180s";
      };

      retention = mkOption {
        type = types.int;
        description = mdDoc "Number of days to retain snapshots for";
        default = "10";
        example = "20";
      };

      snapshotDirectory = mkOption {
        type = lib.types.path;
        default = "/snapshots";
      };
    };
  };

  config.systemd = mkIf cfg.enable {
    managerEnvironment = {
      # forces v/q/Q to create a subvolume if the backing filesystem supports it, even if `/` is not a subvolume itself.
      "SYSTEMD_TMPFILES_FORCE_SUBVOL" = "1";
    };

    tmpfiles.rules =
      [
        # ensure the snapshot base directory is created
        "d ${cfg.snapshotDirectory}"
      ]
      ++ (map (name: "v /var/lib/private/${name}") cfg.services);

    services = mkMerge (
      builtins.map (name: {
        "${name}" = {
          path = with pkgs; [
            btrfs-progs
            e2fsprogs
            jq
          ];
          environment = {
            RETENTION = builtins.toString cfg.retention;
          };
          serviceConfig = {
            ExecStartPre = mkBefore [
              "+${startPre}"
            ];
            ExecStopPost = mkAfter [
              "+${prune}"
              "+${snapshotVolume}"
            ];
            Restart = "always";
            RuntimeMaxSec = cfg.interval;
          };
        };
      })
      cfg.services
    );
  };
}
