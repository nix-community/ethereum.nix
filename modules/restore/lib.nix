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

      strictHostKeyChecking = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Enable or disable strict host key checking";
      };

      unencryptedRepoAccess = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Enable or disable unencrypted repo acceess check";
      };

      lockWait = mkOption {
        type = types.int;
        description = mdDoc "Amount of time in seconds to wait when acquiring a repository lock";
        default = 600;
      };

      encryption.passCommand = mkOption {
        type = with types; nullOr str;
        description = lib.mdDoc ''
          A command which prints the passphrase to stdout.
          Mutually exclusive with {option}`passphrase`.
        '';
        default = null;
        example = "cat /path/to/passphrase_file";
      };

      encryption.passPhrase = mkOption {
        type = with types; nullOr str;
        description = lib.mdDoc ''
          The passphrase the backups are encrypted with.
          Mutually exclusive with {option}`passCommand`.
          If you do not want the passphrase to be stored in the
          world-readable Nix store, use {option}`passCommand`.
        '';
        default = null;
      };
    };

    snapshot = mkOption {
      type = types.str;
      description = mdDoc "The name of the snapshot to restore from";
    };
  };
}
