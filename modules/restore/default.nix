{
  config,
  lib,
  pkgs,
  ...
}: let
  modulesLib = import ../lib.nix lib;
  inherit (modulesLib) findEnabled;

  cfg = with lib;
    filterAttrs (_n: v: v.enable)
    (
      mapAttrs (_: attrByPath ["restore"] {enable = false;})
      (findEnabled config.services.ethereum)
    );

  mkRestoreScript = _cfg:
    pkgs.writeShellScript "restore" ''
      set -euo pipefail

      echo "Running restore"

      # we only perform a restore if the directory is empty
      if [ "$(ls -A $STATE_DIRECTORY)" ]; then
          echo "$STATE_DIRECTORY is not empty, restore will exit"
          exit 0
      fi

      SERVICE_NAME=$(basename $STATE_DIRECTORY)

      $RESTIC_CMD restore \
        --tag "name:$SERVICE_NAME" \
        --target $STATE_DIRECTORY \
        --cache-dir=$CACHE_DIRECTORY \
        $SNAPSHOT

      # fix permissions
      cd $STATE_DIRECTORY
      chown -R $USER:$USER /var/lib/private/$USER
      chmod -R 750 /var/lib/private/$USER

      CONTENT_HASH_FILE="$STATE_DIRECTORY/.backup/content-hash"

      if [ -f $CONTENT_HASH_FILE ]; then
        echo "Content hash detected, performing integrity check"

        # perform integrity check
        CONTENT_HASH=$(find $STATE_DIRECTORY -path $STATE_DIRECTORY/.backup -prune -type f -exec md5sum {} + | LC_ALL=C sort | md5sum)
        EXPECTED_CONTENT_HASH=$(cat $CONTENT_HASH_FILE)

        echo "Content hash: $CONTENT_HASH, expected hash: $EXPECTED_CONTENT_HASH"
        if [[ $CONTENT_HASH != $EXPECTED_CONTENT_HASH ]]; then
          echo "Content hash does not match. Removing contents"
          rm -rf $STATE_DIRECTORY/*
          exit 1
        fi
      fi

      echo "Restoration complete"
    '';

  mkClientService = name: cfg:
    with lib; let
      inherit (cfg) restic;
      extraOptions = concatMapStrings (arg: " -o ${arg}") restic.extraOptions;
      resticCmd = "${pkgs.restic}/bin/restic${extraOptions}";
      # Helper functions for rclone remotes
      rcloneRemoteName = builtins.elemAt (splitString ":" restic.repository) 1;
      rcloneAttrToOpt = v: "RCLONE_" + toUpper (builtins.replaceStrings ["-"] ["_"] v);
      rcloneAttrToConf = v: "RCLONE_CONFIG_" + toUpper (rcloneRemoteName + "_" + v);
      toRcloneVal = v:
        if lib.isBool v
        then lib.boolToString v
        else v;
    in {
      environment =
        {
          SNAPSHOT = cfg.snapshot;
          RESTIC_PASSWORD_FILE = restic.passwordFile;
          RESTIC_REPOSITORY = restic.repository;
          RESTIC_REPOSITORY_FILE = restic.repositoryFile;
          RESTIC_CMD = resticCmd;
        }
        // optionalAttrs (restic.rcloneOptions != null) (mapAttrs'
          (
            name: value:
              nameValuePair (rcloneAttrToOpt name) (toRcloneVal value)
          )
          restic.rcloneOptions)
        // optionalAttrs (restic.rcloneConfigFile != null) {
          RCLONE_CONFIG = restic.rcloneConfigFile;
        }
        // optionalAttrs (restic.rcloneConfig != null) (mapAttrs'
          (
            name: value:
              nameValuePair (rcloneAttrToConf name) (toRcloneVal value)
          )
          restic.rcloneConfig);
      path = [
        pkgs.restic
        pkgs.coreutils
      ];
      serviceConfig = with lib; {
        CacheDirectory = "${name}";
        CacheDirectoryMode = "0700";
        EnvironmentFile = [cfg.restic.environmentFile];
        # btrfs subvolume setup ExecStartPre script if enabled is configured with mkBefore which is equivalent to mkOrder 500
        # we want any potential restore to happen after that so we set our mkOrder to 501
        ExecStartPre = mkOrder 501 [
          "+${mkRestoreScript cfg}"
        ];
        # increase start timeout
        TimeoutStartSec = cfg.timeout;
      };
    };
in {
  config.systemd.services = with lib; mapAttrs mkClientService cfg;
}
