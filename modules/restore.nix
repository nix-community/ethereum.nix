{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ethereum.restore;

  serviceOpts = with lib; {
    options = {
      repo = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = mdDoc "An override for the repository from which to pull the snapshot;";
        example = "user@machine:/path/to/repo";
      };
      keyPath = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = mdDoc "An override path to a private key used for ssh";
      };
      snapshot = mkOption {
        type = types.str;
        description = mdDoc "The name of the snapshot to restore";
      };
    };
  };

  restoreScript = pkgs.writeShellScript "restore" ''
    set -euo pipefail

    echo "Running restore"

    if [ "$(ls -A $STATE_DIRECTORY)" ]; then
        echo "$STATE_DIRECTORY is not empty, restore will exit"
        exit 0
    fi

    # we only perform a restore if the directory is empty

    # move to the correct directory
    cd $STATE_DIRECTORY

    # restore from the repo
    echo "BORG_REPO=$BORG_REPO"
    echo "SNAPSHOT=$SNAPSHOT"
    borg extract --list ::"$SNAPSHOT"

    echo "Restoration complete"
  '';

  instrumentClientService = serviceName: serviceCfg: {
    environment = let
      # get repo, checking for a service specific override
      baseRepo = cfg.borg.repo;
      repo =
        if serviceCfg.repo != null
        then serviceCfg.repo
        else (baseRepo + "/${serviceName}");

      sshKey =
        if serviceCfg.keyPath != null
        then serviceCfg.keyPath
        else cfg.borg.keyPath;
    in {
      SNAPSHOT = serviceCfg.snapshot;
      BORG_REPO = repo;
      BORG_RSH = "ssh -o StrictHostKeyChecking=no -i ${sshKey}";
      # suppress prompts
      BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
    };
    path = with pkgs; [
      borgbackup
    ];
    serviceConfig = {
      # btrfs subvolume setup ExecStartPre script if enabled is configured with mkBefore which is equivalent to mkOrder 500
      # we want any potential restore to happen after that so we set our mkOrder to 501
      ExecStartPre = lib.mkOrder 501 [
        "+${restoreScript}"
      ];
    };
  };
in {
  options.services.ethereum.restore = with lib; {
    enable = mkEnableOption (mdDoc "Enable backup");

    services = mkOption {
      type = types.attrsOf (types.submodule serviceOpts);
      default = {};
      description = mdDoc "Service specific restore options";
    };

    borg = {
      repo = mkOption {
        type = types.str;
        description = mdDoc "Remote or local base repository to restore from. Service name will be appended to this.";
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
    };
  };

  config.systemd.services = with lib;
    mkIf cfg.enable
    (mapAttrs instrumentClientService cfg.services);
}
