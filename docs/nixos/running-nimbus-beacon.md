# Running Nimbus Beacon

One or more [Nimbus Beacon](https://nimbus.guide) services can be configured with the `services.ethereum.nimbus-beacon` prefix.

```nix title="server.nix"
{ pkgs, ...}: {
  services.ethereum.nimbus-beacon.mainnet = {
    enable = true;
    openFirewall = true;
    args = {
      network = "mainnet";
      jwt-secret = secrets.nimbus_jwt_secret.path;
      trusted-node-url = "https://sync.invis.tools";
      rest.enable = true;
    };
  };
  };
}
```

**Note:** It is recommended to use an attribute name that matches the network that Nimbus Beacon is configured for. Unless the [network](./modules/nimbus-beacon.md#servicesethereumnimbus-beaconnameargsnetwork) option is set, the Nimbus Beacon node network will default to the name, eg. `services.ethereum.nimbus-beacon.mainnet` will connect to Ethereum mainnet.

## Configuration

Many of Nimbus's process arguments have been mapped to NixOS types and can be provided via the `args` section of the config.
For a detailed list please refer to the [NixOS Options](./modules/nimbus-beacon.md) reference.

Additional arguments can be provided in a list directly to the Nimbus Beacon process via the `extraArgs` attribute as shown above.

## Systemd service

For each instance that is configured a corresponding [Systemd](https://systemd.io/) service is created. The service name
follows a convention of `nimbus-beacon-${name}.service`.

| Config                                        | Name    | Service name                        |
| :-------------------------------------------- | :------ | :---------------------------------- |
| `services.ethereum.nimbus-beacon.sepolia` | sepolia | `nimbus-beacon-sepolia.service` |
| `services.ethereum.nimbus-beacon.holesky`  | holesky  | `nimbus-beacon-holesky.service`  |
| `services.ethereum.nimbus-beacon.mainnet` | mainnet | `nimbus-beacon-mainnet.service` |

The service that is created can then be introspected and managed via the standard Systemd toolset.

| Action  | Command                                               |
| :------ | :---------------------------------------------------- |
| Status  | `systemctl status nimbus-beacon-sepolia.service`  |
| Stop    | `systemctl stop nimbus-beacon-sepolia.service`    |
| Start   | `systemctl start nimbus-beacon-sepolia.service`   |
| Restart | `systemctl restart nimbus-beacon-sepolia.service` |
| Logs    | `journalctl -xefu nimbus-beacon-sepolia.service`  |

## Checkpoint Sync

Nimbus can be configured to checkpoint sync from a trusted beacon node URL using the [trusted-node-url](./modules/nimbus-beacon.md#servicesethereumnimbus-beaconnameargstrusted-node-url) option. See [The Nimbus Guide](https://nimbus.guide/trusted-node-sync.html) for more information.

When configured, on first startup, Nimbus will download the checkpoint from the configured URL. Subsequent startups will skip this step.

**Note:** Always verify after after a checkpoint sync that the right chain was provided by the node. Instructions to do so are included in the above Nimbus Guide link.

## Using a Nimbus Beacon fork

A different version of Nimbus Beacon can be configured via the [package](./modules/nimbus-beacon.md#servicesethereumnimbus-beaconnamepackage) option.

To configure a custom fork for example:

```nix title="server.nix"
{ pkgs, ...}: {
  services.ethereum.nimbus-beacon.sepolia = {
    enable = true;
    package = pkgs.my-nimbus-beacon;
    ...
  };
}
```

## Opening ports

By default, [openFirewall](./modules/nimbus-beacon.md#servicesethereumnimbus-beaconnameopenfirewall) is set to `false`.
If set to `true` firewall rules are added which will expose the following ports:

| Protocol | Config                                                                                                   | Default value |
| :------- | :------------------------------------------------------------------------------------------------------- | :------------ |
| TCP      | [tcp-port](./modules/nimbus-beacon.md#servicesethereumnimbus-beaconnameargstcp-port) | 9000          |
| UDP      | [udp-port](./modules/nimbus-beacon.md#servicesethereumnimbus-beaconnameargsudp-port) | 9000          |
| TCP      | [rest-port](./modules/nimbus-beacon.md#servicesethereumnimbus-beaconnameargsrest-port)           | 5052          |

**Note:** it is important when running multiple instances of Nimbus Beacon on the same machine that you ensure they are configured with different ports.
