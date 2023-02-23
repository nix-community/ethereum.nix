lib: {
  options = with lib; {
    enable = mkEnableOption (mdDoc "Enable backup");

    snapshot = {
      enable = mkEnableOption (mdDoc "Enable btrfs snapshots");

      retention = mkOption {
        type = types.int;
        description = mdDoc "Number of days to retain snapshots";
        default = 7;
        example = "10";
      };

      directory = mkOption {
        type = types.path;
        description = mdDoc "Directory in which to create the btrfs snapshots";
        default = "/snapshots";
      };
    };

    schedule = mkOption {
      type = types.str;
      description = mdDoc "Time interval for running a snapshot and backup. Format is the same as systemd.time";
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
          # private to a node
          "keystore"
          "geth/nodekey"
          # metadata related to backup process
          ".exit-status"
          ".metadata.json"
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
  };
}
