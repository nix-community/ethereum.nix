lib: {
  options = with lib; {
    enable = mkEnableOption "Enable restore from snapshot";

    snapshot = mkOption {
      type = types.str;
      description = "The id of the snapshot to restore from";
    };

    timeout = mkOption {
      type = types.int;
      description = "The max time to wait before timing out on startup. This value is used for TimeoutStartSec in the systemd service config.";
      default = 600;
      example = "900";
    };

    restic = import ../backup/restic.nix lib;
  };
}
