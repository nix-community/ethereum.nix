lib: {
  options = with lib; {
    enable = mkEnableOption "Enable backup";

    btrfs = {
      enable = mkEnableOption "Enable btrfs snapshots for the state directory, if supported by the underlying filesystem";

      snapshotRetention = mkOption {
        type = types.int;
        description = "Number of days to retain snapshots";
        default = 7;
        example = "10";
      };

      snapshotDirectory = mkOption {
        type = types.path;
        description = ''
          Directory in which to create the btrfs snapshots. Must be located on the same volume as the state directory
        '';
        default = "/snapshots";
      };
    };

    metadata.interval = mkOption {
      type = types.ints.between 1 60;
      description = "Time interval in seconds between capturing backup metadata";
      default = 10;
    };

    schedule = mkOption {
      type = types.str;
      description = "Schedule for creating a backup. Format is the same as systemd.time";
      default = "hourly";
      example = "daily";
    };

    restic = import ./restic.nix lib;
  };
}
