lib: {
  options = with lib; {
    enable = mkEnableOption (mdDoc "Enable backup");

    btrfs = {
      enable = mkEnableOption (mdDoc "Enable btrfs snapshots for the state directory, if supported by the underlying filesystem");

      snapshotRetention = mkOption {
        type = types.int;
        description = mdDoc "Number of days to retain snapshots";
        default = 7;
        example = "10";
      };

      snapshotDirectory = mkOption {
        type = types.path;
        description = mdDoc ''
          Directory in which to create the btrfs snapshots. Must be located on the same volume as the state directory
        '';
        default = "/snapshots";
      };
    };

    metadata.interval = mkOption {
      type = types.ints.between 1 60;
      description = mdDoc "Time interval in seconds between capturing backup metadata";
      default = 10;
    };

    schedule = mkOption {
      type = types.str;
      description = mdDoc "Schedule for creating a backup. Format is the same as systemd.time";
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
        type = types.nullOr types.path;
        description = mdDoc "Path to a private key used for ssh";
        default = null;
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
        default = 3600;
      };

      exclude = mkOption {
        type = with types; listOf str;
        description = lib.mdDoc ''
          Exclude paths matching any of the given patterns. See
          {command}`borg help patterns` for pattern syntax.
        '';
        default = [
          # private to a node
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

      encryption.mode = mkOption {
        type = types.enum [
          "repokey"
          "keyfile"
          "repokey-blake2"
          "keyfile-blake2"
          "authenticated"
          "authenticated-blake2"
          "none"
        ];
        description = lib.mdDoc ''
          Encryption mode to use. Setting a mode
          other than `"none"` requires
          you to specify a {option}`passCommand`
          or a {option}`passphrase`.
        '';
        example = "repokey-blake2";
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
  };
}
