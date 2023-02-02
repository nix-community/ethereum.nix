{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mdDoc types mkOption mkEnableOption mkIf filterAttrs attrValues forEach;
  inherit (builtins) concatStringsSep attrNames map;

  # todo is there a better way to do this?
  servicePrefixes = [
    "geth"
    "erigon"
    "prysm"
  ];

  serviceRegex = "^(" + concatStringsSep "|" servicePrefixes + ").*";

  snapshotOptions = {
    enable = mkEnableOption (mdDoc "Enable state directory snapshots");
  };

  cfg = config.services.ethereum.snapshot;

  serviceConfigs = filterAttrs (n: _: (builtins.match serviceRegex n) != null) config.systemd.services;
  serviceNames = attrNames serviceConfigs;
in {
  options = {
    services.ethereum.snapshot = {
      enable = mkEnableOption (mdDoc "Enable snapshotting");
    };
  };

  config = mkIf cfg.enable {
    systemd.managerEnvironment = {
      # forces v/q/Q to create a subvolume if the backing filesystem supports it, even if `/` is not a subvolume itself.
      "SYSTEMD_TMPFILES_FORCE_SUBVOL" = "1";
    };

    systemd.tmpfiles.rules = map (name: "v /var/lib/private/${name}") serviceNames;
  };
}
