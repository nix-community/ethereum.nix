# Configuring backups

The following service modules support backups:

- [Geth](./running-geth.md)
- [Prysm Beacon](./running-prysm-beacon.md)
- [Nethermind](./running-nethermind.md)

Backup functionality is currently implemented with [Borg Backup](https://www.borgbackup.org/).

At some point in the future this may be expanded to other backup solutions such as [Restic](https://restic.net/).

## Backup providers

Storage boxes, such as those available from [Hetzner](https://www.hetzner.com/storage/storage-box), support Borg Backup
by default.

Alternatively it is straightforward to set up a backup server using NixOS.

```nix title="backup-server.nix"
{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.borgbackup
  ];

  services.borgbackup.repos.ethereum = {
    path = "/data/borgbackup/ethereum";
    # Allow clients to create repositories in subdirectories of the specified path
    allowSubRepos = true;
    # Public SSH keys that can only be used to append new data (archives) to the repository
    authorizedKeysAppendOnly = [
      "ssh-ed25519 AAAAC3N..."
    ];
  };
}
```

For a detailed list of options please [see here](https://search.nixos.org/options?channel=22.11&show=services.borgbackup.repos&from=0&size=50&sort=relevance&type=packages&query=borg).

## Basic configuration

Backup options are set inside the `backup` section of supporting modules.

```nix title="server.nix"
{ pkgs, ...}: {
  services.ethereum.geth.sepolia = {
    ...

    backup = {
      enable = true;

      borg = {
        repo = "ssh://borg@backup.server/data/borgbackup/ethereum/geth-sepolia";
        keyPath = "/root/ed25519";
        encryption.mode = "none";
        unencryptedRepoAccess = true;
      };
    };
  };
}
```

## Systemd services

When backups are enabled for a given Ethereum service several new Systemd services and timers will be introduced to
facilitate the backup process.

For an instance of Geth named `sepolia` for example, the following services will be added:

- `geth-sepolia-metadata.service` which captures metadata such as chain height and persists it in the state directory.
- `geth-sepolia-metadata.timer` which triggers the metadata service every 10 seconds by default. This interval is configurable via [metadata.interval](../reference/module-options/geth.md#servicesethereumgethnamebackupmetadatainterval).
- `geth-sepolia-backup.service` which is responsible for stopping `geth-sepolia.service`, backing up its state directory, and restarting it.
- `geth-sepolia-backup.timer` which triggers the backup service once daily by default. This schedule is configurable via [backup.schedule](../reference/module-options/geth.md#servicesethereumgethnamebackupschedule).

## Borg Backup

### Repository layout

Archives within a repository are named using the last recorded chain height, as determined by the metadata service for the respective process.

Here is a sample list of archives for an instance of Geth.

```terminal
backup# borg list geth-sepolia
2851887                              Tue, 2023-02-07 13:55:54 [3e7c1be0554e9120ed61da89a98301ebc578409e8941ba216528398f16232ac6]
2852055                              Tue, 2023-02-07 13:57:28 [f8b114fc69719c987dd8126625ddd41c042f6c0a17591764a8a79e490e3e7085]
2852078                              Tue, 2023-02-07 14:20:14 [9ab743fb58f3e1184dcef9ec69c591f4f399d171c2b70f51c8ba6b300e8b554b]
2852102                              Tue, 2023-02-07 14:20:42 [19e85cc31d5c9e4609f5a3b2e71c5e2490548173de076f21f1101e4ed9e301ee]
```

### Host key checking

Borg Backup uses ssh when connecting to a remote repository and as such requires an ssh private key. This key path can be provided
via the [keyPath](../reference/module-options/geth.md#servicesethereumgethnamebackupborgkeypath) option.

When connecting to a backup host for the first time a backup may fail if the provided host key has not been added to the
remote machine's known host list.

For testing and development purposes this check can be disabled via the [strictHostKeyChecking](../reference/module-options/geth.md#servicesethereumgethnamebackupborgstricthostkeychecking) option.

For production setups it is recommended to update the remote server's known host list first before any backups are scheduled.

```nix title="server.nix"
{ pkgs, ...}: {
  services.ethereum.geth.sepolia = {
    ...

    backup = {
      enable = true;

      borg = {
        repo = "ssh://borg@dione/data/borgbackup/ethereum/geth-sepolia";
        keyPath = "/root/ed25519";
        strictHostKeyChecking = false;
      };

      schedule = "0/1:00:00";
    };
  };
}
```

### Repository encryption

There are several encryption schemes available for securing backup repositories.

**Note: ** The encryption mode can only be configured when creating a new repository - you can neither configure it on a per-archive basis nor change the encryption mode of an existing repository.

If the encryption mode is set to `none` it is necessary to set `unencryptedRepoAccess` to `true` otherwise the backup process
will fail to connect to the backup repository.

```nix title="server.nix"
{ pkgs, ...}: {
  services.ethereum.geth.sepolia = {
    ...
    backup = {
      enable = true;

      borg = {
        repo = "ssh://borg@backup.server/data/borgbackup/ethereum/geth-sepolia";
        keyPath = "/root/ed25519";
        encryption.mode = "none";
        unencryptedRepoAccess = true;
      };
    };
  };
}
```

For an overview of the encryption schemes available please refer to the [borg backup official docs](https://borgbackup.readthedocs.io/en/stable/usage/init.html).

Suitable corresponding NixOS options for configuring encryption [are available](../reference/module-options/geth.md#servicesethereumgethnamebackupborgencryptionmode).
