# adapted from https://github.com/NixOS/nixpkgs/blob/nixos-22.11/nixos/modules/services/backup/restic.nix
lib:
with lib; {
  passwordFile = mkOption {
    type = types.str;
    description = ''
      Read the repository password from a file.
    '';
    example = "/etc/nixos/restic-password";
  };

  environmentFile = mkOption {
    type = with types; nullOr str;
    default = null;
    description = ''
      file containing the credentials to access the repository, in the
      format of an EnvironmentFile as described by systemd.exec(5)
    '';
  };

  rcloneOptions = mkOption {
    type = with types; nullOr (attrsOf (oneOf [str bool]));
    default = null;
    description = ''
      Options to pass to rclone to control its behavior.
      See <https://rclone.org/docs/#options> for
      available options. When specifying option names, strip the
      leading `--`. To set a flag such as
      `--drive-use-trash`, which does not take a value,
      set the value to the Boolean `true`.
    '';
    example = {
      bwlimit = "10M";
      drive-use-trash = "true";
    };
  };

  rcloneConfig = mkOption {
    type = with types; nullOr (attrsOf (oneOf [str bool]));
    default = null;
    description = ''
      Configuration for the rclone remote being used for backup.
      See the remote's specific options under rclone's docs at
      <https://rclone.org/docs/>. When specifying
      option names, use the "config" name specified in the docs.
      For example, to set `--b2-hard-delete` for a B2
      remote, use `hard_delete = true` in the
      attribute set.
      Warning: Secrets set in here will be world-readable in the Nix
      store! Consider using the `rcloneConfigFile`
      option instead to specify secret values separately. Note that
      options set here will override those set in the config file.
    '';
    example = {
      type = "b2";
      account = "xxx";
      key = "xxx";
      hard_delete = true;
    };
  };

  rcloneConfigFile = mkOption {
    type = with types; nullOr path;
    default = null;
    description = ''
      Path to the file containing rclone configuration. This file
      must contain configuration for the remote specified in this backup
      set and also must be readable by root. Options set in
      `rcloneConfig` will override those set in this
      file.
    '';
  };

  repository = mkOption {
    type = with types; nullOr str;
    default = null;
    description = ''
      repository to backup to.
    '';
    example = "sftp:backup@192.168.1.100:/backups/my-bucket";
  };

  repositoryFile = mkOption {
    type = with types; nullOr path;
    default = null;
    description = ''
      Path to the file containing the repository location to backup to.
    '';
  };

  exclude = mkOption {
    type = types.listOf types.str;
    default = [
      "**/LOCK"
      "keystore"
      "**/nodekey"
    ];
    description = ''
      Patterns to exclude when backing up. See
      https://restic.readthedocs.io/en/latest/040_backup.html#excluding-files for
      details on syntax.
    '';
    example = [
      "/var/cache"
      "/home/*/.cache"
      ".git"
    ];
  };

  extraOptions = mkOption {
    type = types.listOf types.str;
    default = [];
    description = ''
      Extra extended options to be passed to the restic --option flag.
    '';
    example = [
      "sftp.command='ssh backup@192.168.1.100 -i /home/user/.ssh/id_rsa -s sftp'"
    ];
  };
}
