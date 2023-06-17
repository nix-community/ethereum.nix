# Restoring from a backup

The following service modules support restoring from backups:

- [Geth](./running-geth.md)
- [Prysm Beacon](./running-prysm-beacon.md)

For an overview of how to configure backups please [see here](./backup-and-restore.md)

## Basic configuration

Restore options are set inside the `restore` section of supporting modules.

```nix title="server.nix"
{ pkgs, ...}: {
  services.ethereum.geth.sepolia = {
    ...
    restore = {
      enable = true;
      snapshot = "3090378";

      borg = {
        repo = "ssh://borg@backup.server/data/borgbackup/ethereum/geth-sepolia";
        keyPath = "/root/ed25519";
        unencryptedRepoAccess = true;
      };
    };
  };
}
```

## Borg Backup

### Host key checking

Borg Backup uses ssh when connecting to a remote repository and as such requires an ssh private key. This key path can be provided
via the [keyPath](../reference/module-options/geth.md#servicesethereumgethnamebackupborgkeypath) option.

When connecting to a backup host for the first time a restoration may fail if the provided host key has not been added to the
remote machine's known host list.

For testing and development purposes this check can be disabled via the [strictHostKeyChecking](../reference/module-options/geth.md#servicesethereumgethnamebackupborgstricthostkeychecking) option.

For production setups it is recommended to update the remote server's known host list first before any backups are scheduled.

```nix title="server.nix"
{ pkgs, ...}: {
  services.ethereum.geth.sepolia = {
    ...

    restore = {
      enable = true;
      snapshot = "3090378";

      borg = {
        repo = "ssh://borg@dione/data/borgbackup/ethereum/geth-sepolia";
        keyPath = "/root/ed25519";
        strictHostKeyChecking = false;
      };
    };
  };
}
```

### Repository encryption

There are several encryption schemes available for securing backup repositories.

**Note: ** The encryption mode can only be configured when creating a new repository - you can neither configure it on a per-archive basis nor change the encryption mode of an existing repository.

For an overview of the encryption schemes available please refer to the [borg backup official docs](https://borgbackup.readthedocs.io/en/stable/usage/init.html).

Suitable corresponding NixOS options for configuring encryption [are available](../reference/module-options/geth.md#servicesethereumgethnamebackupborgencryptionmode).
