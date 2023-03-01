{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  modulesLib = import ../lib.nix {inherit lib pkgs;};
  inherit (modulesLib) findEnabled;

  cfg = with lib;
    filterAttrs (n: v: v.enable)
    (
      mapAttrs (_: v: attrByPath ["restore"] {enable = false;} v)
      (findEnabled config.services.ethereum)
    );

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

  mkClientService = name: cfg: {
    environment = {
      SNAPSHOT = cfg.snapshot;
      BORG_REPO = cfg.borg.repo;
      BORG_RSH = "ssh -o StrictHostKeyChecking=no -i ${cfg.borg.keyPath}";
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
  config.systemd.services = with lib; mapAttrs mkClientService cfg;
}
