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
      mapAttrs (_: attrByPath ["restore"] {enable = false;})
      (findEnabled config.services.ethereum)
    );

  mkRestoreScript = cfg: pkgs.writeShellScript "restore" ''
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

    borg extract --lock-wait ${builtins.toString cfg.borg.lockWait} --list ::"$SNAPSHOT"

    echo "Restoration complete"
  '';

  mkClientService = name: cfg: {
    environment = with lib; {
      SNAPSHOT = cfg.snapshot;
      BORG_REPO = cfg.borg.repo;
      BORG_RSH =
        mkDefault
        (concatStringsSep " " [
          "ssh"
          (optionalString (!cfg.borg.strictHostKeyChecking) "-o StrictHostKeyChecking=no")
          (optionalString (cfg.borg.keyPath != null) "-i ${cfg.borg.keyPath}")
        ]);
      BORG_PASSCOMMAND =
        mkIf
        (cfg.borg.encryption.passCommand != null)
        cfg.borg.encryption.passCommand;
      BORG_PASSPHRASE =
        mkIf
        (cfg.borg.encryption.passPhrase != null)
        cfg.borg.encryption.passPhrase;
      # suppress prompts
      BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = mkDefault (
        if cfg.borg.unencryptedRepoAccess
        then "yes"
        else "no"
      );
    };
    path = with pkgs; [
      borgbackup
    ];
    serviceConfig = with lib; {
      # btrfs subvolume setup ExecStartPre script if enabled is configured with mkBefore which is equivalent to mkOrder 500
      # we want any potential restore to happen after that so we set our mkOrder to 501
      ExecStartPre = mkOrder 501 [
        "+${mkRestoreScript cfg}"
      ];
    };
  };
in {
  config.systemd.services = with lib; mapAttrs mkClientService cfg;
}
