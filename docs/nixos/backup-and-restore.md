# Backup and restore

The following service modules support backups:

- [Geth](./running-geth.md)
- [Prysm Beacon](./running-prysm-beacon.md)

Backup and restore functionality is implemented with [Restic](https://restic.net/).

## Storage providers

At the time of writing [Restic supports](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html) the following storage backends:

- Local
- SFTP
- REST Server
- Amazon S3
- Minio Server
- Wasabi
- Alibaba Cloud Object Storage System
- OpenStack Swift
- Backblaze B3
- Microsoft Azure Blob Storage
- Google Cloud Storage
- Other services vis RClone

## Configuring backups

Backup options are set inside the `backup` section of supporting modules.

```nix title="backup.nix"
{ pkgs, ...}: {
  services.ethereum.geth.sepolia = {
    ...
    backup = {
      enable = true;
      schedule = "0/1:00:00";
      restic = {
        repository = "s3:http://dione:9000/geth-sepolia";
        passwordFile = sops.secrets.restic_password.path;
        environmentFile = sops.secrets.restic_env.path;
      };
    };
  };
}
```

By default, backups are scheduled daily. This can be modified through the [schedule](../reference/module-options/geth.md#servicesethereumgethnamebackupschedule) option which follows the same format as [systemd.time](https://manpages.org/systemdtime/7).

To access a Restic repository, a password (also called a key) must be specified. This can be done via `restic.passwordFile`.

And since Restic can be configured with a wide variety of storage providers, an environment file can be provided to accommodate their configuration.
When using an [Amazon S3](https://aws.amazon.com/s3/) backend for example the environment file might look like this:

```env title="aws.env"
AWS_DEFAULT_REGION=eu-west-1
AWS_ACCESS_KEY_ID=my_access_key
AWS_SECRET_ACCESS_KEY=my_secret_key
```

For a detailed list of options please [see here](../reference/module-options/geth.md#servicesethereumgethnamebackupenable).

### Systemd services

When backups are enabled several new Systemd services and timers will be introduced to facilitate the backup process.

For an instance of Geth named `sepolia` for example, the following services will be added:

- `geth-sepolia-metadata.service` which captures metadata such as chain height and persists it in the state directory.
- `geth-sepolia-metadata.timer` which triggers the metadata service every 10 seconds by default. This interval is configurable via [metadata.interval](../reference/module-options/geth.md#servicesethereumgethnamebackupmetadatainterval).
- `geth-sepolia-backup.service` which is responsible for stopping `geth-sepolia.service`, backing up its state directory, and restarting it.
- `geth-sepolia-backup.timer` which triggers the backup service once daily by default. This schedule is configurable via [backup.schedule](../reference/module-options/geth.md#servicesethereumgethnamebackupschedule).

## Restoring from backup

Restore options are set inside the `restore` section of supporting modules and share many of the same config options as
[backups](#configuring-backups).

```nix title="restore.nix"
{ pkgs, ...}: {
  services.ethereum.geth.sepolia = {
    ...
    restore = {
      enable = true;
      snapshot = "latest";
      restic = {
        repository = "s3:http://dione:9000/geth-sepolia";
        passwordFile = sops.secrets.restic_password.path;
        environmentFile = sops.secrets.restic_env.path;
      };
    };
  };
}
```

The one key difference is the `snapshot` option which details which snapshot to restore from. This can be `latest` as
seen in the example above, or a specific snapshot id as listed by running `restic snapshots`:

```terminal
❯ restic snapshots -c | head
ID        Time                 Host    Tags
-------------------------------------------------------------------------------------------------------------------
5e2006e9  2023-03-22 07:00:07  phoebe  height:3139753
                                       number:0x2fe8a9
                                       stateRoot:0x1be15cbc48fbd1ddb2fee1332f5fd6eacca60a737b4e87874c82be32810b19a5
                                       hash:0x04a53f7cc92888de4ea743419855abdfff4ba84454db211846d984609578b265
                                       name:geth-sepolia
bdf903fc  2023-03-22 08:00:18  phoebe  height:3140008
                                       number:0x2fe9a8
                                       stateRoot:0xac1fd086f4e5afe152afd110f67ce86a5787895ca75c3fffa516229fc10ec9b2
                                       hash:0x330594bc56d97b30c9794f33c692f32f3e29a6de1acb495cc4e66b0a437dc4c3
                                       name:geth-sepolia
e83e3f49  2023-03-22 09:00:17  phoebe  height:3140256
                                       number:0x2feaa0
                                       stateRoot:0x0a82d296b70638063187208707681d8976769594e65cd823da7429e215cce2a7
                                       hash:0x6b39cfca2375b0cfb11e59c9f159e7a19108aa25cfbf4a88de53a9c1e089e233
                                       name:geth-sepolia
```

**Note:** restoring from backup will _only be attempted_ if the state directory for the service in question is empty. The
presence of any files will cause the restoration attempt to be aborted.

This means it is safe to leave the restore config in place as it only has an effect when initialising a fresh instance.
