lib: {
  options = with lib; {
    enable = mkEnableOption (mdDoc "Enable restore from snapshot");

    snapshot = mkOption {
      type = types.str;
      description = mdDoc "The id of the snapshot to restore from";
    };

    restic = import ../backup/restic.nix lib;
  };
}
