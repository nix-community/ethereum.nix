lib: {
  options = with lib; {
    enable = mkEnableOption (mdDoc "Enable restore from snapshot");

    borg = {
      repo = mkOption {
        type = types.str;
        description = mdDoc "The repository from which to pull the snapshot";
        example = "user@machine:/path/to/repo";
      };
      keyPath = mkOption {
        type = types.path;
        description = mdDoc "A path to a private key used for ssh";
      };
    };

    snapshot = mkOption {
      type = types.str;
      description = mdDoc "The name of the snapshot to restore from";
    };
  };
}
