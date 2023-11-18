# Running Lighthouse Beacon

One or more [Lighthouse Beacon](https://lighthouse-book.sigmaprime.io/intro.html) services can be configured with the `services.ethereum.lighthouse-beacon` prefix.

```nix title="server.nix"
{ pkgs, ...}: {
  services.ethereum.lighthouse-beacon.sepolia = {
    enable = true;
    openFirewall = true;
    args = {
      network = "sepolia"; # (Optional) defaults to beacon name
      execution-jwt = secrets.lighthouse_jwt_secret.path;
      checkpoint-sync-url = "https://sepolia.checkpoint-sync.ethdevops.io";
      genesis-state-url = "https://sepolia.checkpoint-sync.ethdevops.io";
    };
    http-address = "0.0.0.0";
  };

  services.ethereum.lighthouse-beacon.goerli = {
    enable = true;
    ...
  };
}
```

**Note:** It is recommended to use an attribute name that matches the network that Lighthouse Beacon is configured for.

## Configuration

Many of Lighthouse Beacon's process arguments have been mapped to NixOS types and can be provided via the `args` section of the config.
For a detailed list please refer to the [NixOS Options](./modules/lighthouse-beacon.md) reference.

Additional arguments can be provided in a list directly to the Lighthouse Beacon process via the `extraArgs` attribute as shown above.

## Systemd service

For each instance that is configured a corresponding [Systemd](https://systemd.io/) service is created. The service name
follows a convention of `lighthouse-beacon-${name}.service`.

| Config                                        | Name    | Service name                        |
| :-------------------------------------------- | :------ | :---------------------------------- |
| `services.ethereum.lighthouse-beacon.sepolia` | sepolia | `lighthouse-beacon-sepolia.service` |
| `services.ethereum.lighthouse-beacon.goerli`  | goerli  | `lighthouse-beacon-goerli.service`  |
| `services.ethereum.lighthouse-beacon.mainnet` | mainnet | `lighthouse-beacon-mainnet.service` |

The service that is created can then be introspected and managed via the standard Systemd toolset.

| Action  | Command                                               |
| :------ | :---------------------------------------------------- |
| Status  | `systemctl status lighthouse-beacon-sepolia.service`  |
| Stop    | `systemctl stop lighthouse-beacon-sepolia.service`    |
| Start   | `systemctl start lighthouse-beacon-sepolia.service`   |
| Restart | `systemctl restart lighthouse-beacon-sepolia.service` |
| Logs    | `journalctl -xefu lighthouse-beacon-sepolia.service`  |

## Using a Lighthouse Beacon fork

A different version of Lighthouse Beacon can be configured via the [package](./modules/lighthouse-beacon.md#servicesethereumlighthouse-beaconnamepackage) option.

To configure a custom fork for example:

```nix title="server.nix"
{ pkgs, ...}: {
  services.ethereum.lighthouse-beacon.sepolia = {
    enable = true;
    package = pkgs.my-lighthouse-beacon;
    ...
  };
}
```

## Opening ports

By default, [openFirewall](./modules/lighthouse-beacon.md#servicesethereumlighthouse-beaconnameopenfirewall) is set to `false`.
If set to `true` firewall rules are added which will expose the following ports:

| Protocol | Config                                                                                                   | Default value |
| :------- | :------------------------------------------------------------------------------------------------------- | :------------ |
| UDP      | [discovery-port](./modules/lighthouse-beacon.md#servicesethereumlighthouse-beaconnameargsdiscovery-port) | 9000          |
| UDP/TCP  | [quic-port](./modules/lighthouse-beacon.md#servicesethereumlighthouse-beaconnameargsquic-port)           | 9001          |
| TCP      | [http-port](./modules/lighthouse-beacon.md#servicesethereumlighthouse-beaconnameargshttp-port)           | 5052          |

**Note:** it is important when running multiple instances of Lighthouse Beacon on the same machine that you ensure they are configured
with different ports.
