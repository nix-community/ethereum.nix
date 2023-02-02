{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mdDoc types mkOption mkEnableOption mkIf mkAfter mkMerge filterAttrs attrValues forEach mapAttrs;
  inherit (builtins) concatStringsSep attrNames map;

  cfg = config.services.ethereum.snapshot;

  # TODO remove hardcoding of /var/lib/private in paths below

  startPre = pkgs.writeShellScript "setup-volume" ''
    set -euo pipefail

    # determing the private path to the volume mount
    SERVICE_NAME=$(basename $STATE_DIRECTORY)
    VOLUME_DIR=/var/lib/private/$SERVICE_NAME

    # ensure cowdata is disabled
    ${pkgs.e2fsprogs}/bin/chattr +C $VOLUME_DIR
  '';

  stopPost = pkgs.writeShellScript "snapshot-volume" ''
    set -euo pipefail

    # check it was a clean shutdown before snapshotting
    if [ $EXIT_STATUS -ne 0 ]; then
        echo "Unclean shutdown detected: $EXIT_CODE, skipping snapshot"
        exit 1
    fi

    # determing the private path to the volume mount
    SERVICE_NAME=$(basename $STATE_DIRECTORY)
    VOLUME_DIR=/var/lib/private/$SERVICE_NAME

    # ensure snapshot directory exists
    ${pkgs.coreutils}/bin/mkdir -p ${cfg.snapshotDirectory}

    # ISO 8601 date
    TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S%:z")

    ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r $VOLUME_DIR ${cfg.snapshotDirectory}/$SERVICE_NAME-$TIMESTAMP
  '';
in {
  options = {
    services.ethereum.snapshot = {
      enable = mkEnableOption (mdDoc "Enable snapshotting");

      services = mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
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

    tmpfiles.rules = map (name: "v /var/lib/private/${name}") cfg.services;

    services = mkMerge (
      builtins.map (name: {
        "${name}" = {
          serviceConfig = {
            ExecStartPre = "+${startPre}";
            ExecStopPost = "+${stopPost}";
          };
        };
      })
      cfg.services
    );
  };
}
