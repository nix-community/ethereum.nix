# Running Prysm Beacon

One or more [Prysm Beacon](https://docs.prylabs.network/docs/how-prysm-works/beacon-node) services can be configured with the `services.ethereum.prysm-beacon` prefix.

```nix title="server.nix"
{pkgs, ...}: {
  services.ethereum.prysm-beacon.sepolia = {
    enable = true;
    openFirewall = true;
    args = {
      network = "sepolia";
      jwt-secret = secrets.prysm_jwt_secret.path;
      checkpoint-sync-url = "https://sepolia.checkpoint-sync.ethdevops.io";
      genesis-beacon-api-url = "https://sepolia.checkpoint-sync.ethdevops.io";
    };
    extraArgs = [
      "--rpc-host=0.0.0.0"
      "--monitoring-host=0.0.0.0"
    ];
  };

  services.ethereum.prysm-beacon.goerli = {
    enable = true;
    # More options...
  };
}
```

**Note:** It is recommended to use an attribute name that matches the network that Prysm Beacon is configured for.

## Configuration

Many of Prysm Beacon's process arguments have been mapped to NixOS types and can be provided via the `args` section of the config.
For a detailed list please refer to the [NixOS Options](./modules/prysm-beacon.md) reference.

Additional arguments can be provided in a list directly to the Prysm Beacon process via the `extraArgs` attribute as shown above.

## Systemd service

For each instance that is configured a corresponding [Systemd](https://systemd.io/) service is created. The service name
follows a convention of `prysm-beacon-${name}.service`.

| Config                                   | Name    | Service name                   |
| :--------------------------------------- | :------ | :----------------------------- |
| `services.ethereum.prysm-beacon.sepolia` | sepolia | `prysm-beacon-sepolia.service` |
| `services.ethereum.prysm-beacon.goerli`  | goerli  | `prysm-beacon-goerli.service`  |
| `services.ethereum.prysm-beacon.mainnet` | mainnet | `prysm-beacon-mainnet.service` |

The service that is created can then be introspected and managed via the standard Systemd toolset.

| Action  | Command                                          |
| :------ | :----------------------------------------------- |
| Status  | `systemctl status prysm-beacon-sepolia.service`  |
| Stop    | `systemctl stop prysm-beacon-sepolia.service`    |
| Start   | `systemctl start prysm-beacon-sepolia.service`   |
| Restart | `systemctl restart prysm-beacon-sepolia.service` |
| Logs    | `journalctl -xefu prysm-beacon-sepolia.service`  |

## Using a Prysm Beacon fork

A different version of Prysm Beacon can be configured via the [package](./modules/prysm-beacon.md#servicesethereumprysm-beaconnamepackage) option.

To configure a custom fork for example:

```nix title="server.nix"
{pkgs, ...}: {
  services.ethereum.prysm-beacon.sepolia = {
    enable = true;
    package = pkgs.my-prysm-beacon;
    # More options ...
  };
}
```

## Opening ports

By default, [openFirewall](./modules/prysm-beacon.md#servicesethereumprysm-beaconnameopenfirewall) is set to `false`.
If set to `true` firewall rules are added which will expose the following ports:

| Protocol | Config                                                                                                                 | Default value |
| :------- | :--------------------------------------------------------------------------------------------------------------------- | :------------ |
| `UDP`      | [p2p-udp-port](./modules/prysm-beacon.md#servicesethereumprysm-beaconnameargsp2p-udp-port)           | 12000         |               |
| `TCP`      | [p2p-tcp-port](./modules/prysm-beacon.md#servicesethereumprysm-beaconnameargsp2p-tcp-port)           | 13000         |               |
| `TCP`      | [grpc-gateway-port](./modules/prysm-beacon.md#servicesethereumprysm-beaconnameargsgrpc-gateway-port) | 3500          |               |
| `TCP`      | [monitoring-port](./modules/prysm-beacon.md#servicesethereumprysm-beaconnameargsmonitoring-port)     | 8080          |               |
| `TCP`      | [pprofport](./modules/prysm-beacon.md#servicesethereumprysm-beaconnameargspprofport)                 | 8080          |               |

**Note:** it is important when running multiple instances of Prysm Beacon on the same machine that you ensure they are configured
with different ports.
