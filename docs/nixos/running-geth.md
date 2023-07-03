# Running Geth

One or more [Geth](https://github.com/ethereum/go-ethereum) services can be configured with the `services.ethereum.geth` prefix.

```nix title="server.nix"
{pkgs, ...}: {
  services.ethereum.geth.sepolia = {
    enable = true;
    package = pkgs.geth;
    openFirewall = true;
    args = {
      syncmode = "full";
      network = "sepolia";
      http = {
        enable = true;
        addr = "0.0.0.0";
        vhosts = ["localhost" "phoebe"];
        api = ["net" "web3" "eth"];
      };
      authrpc.jwtsecret = sops.secrets.geth_jwt_secret.path;
    };
    extraArgs = [
      "--bootnodes"
      "enode://8ae4559db1b1e160be8cc46018d7db123ed6d03fbbfe481da5ec05f71f0aa4d5f4b02ad059127096aa994568706a0d02933984083b87c5e1e3de2b7692444d37@35.161.233.158:46855,enode://d0b3b290422f35ec3e68356f3a4cdf9c661f71a868110670e31441a5021d7abd0440ae8dfb9360aafdd0198f177863361e3a7a7eb5e1a3e26575bf1ac3ef4ab3@162.19.136.65:48264,enode://d64624bda3cdb65d542c90757a4a661cfe9dddf8328bdb1ea97a8d70fad287c360f0101c492d8fd6ab30d79160a3bf148cacfd68f5d2e47eab0b709516419304@51.195.63.10:30040,enode://c7df835939e027325c6bba926220fae5912a33c83d96b3eef8ef445c98083f3191788581c9a0e8f74cadb0b13229b847f5c1ebd315b22bcf11faf6468020eb48@54.163.51.157:30303,enode://da0609bad3afcab9b93175a41a2d621d07aa7ff6c134a00792d4541f0ce8d30d8f3c51bb37a47573508a0bf18865b04066af2a661edf1d3a3d8d133fc1031aa0@88.151.101.14:45192,enode://7a4534d392c59369eae6befa56ac670476d9edc16597cf53c92bbefa6e741b6b0b9e6822cab12afb09123e03ca1131026fbef145adec429fe2e50182dfb650a5@94.130.18.108:31312,enode://db6fa13b63a885440de581ee3fc8df9c6a590326b39fc5ccba7991707ee0cebac306211f7eca5270a350201a3132511f2338481edd81f3dc819c2a1c60419cf2@65.21.89.157:30303,enode://fcf03e9404cace34c60e4eed374ef9a779471014319b3346352fbc2f992a399af6517486e8e65a4ab55f4645fe55420bbea1cddc13a4af4df63b0f731915c6a6@13.125.238.49:46173,enode://8b973816278fdd56966709e4794c7ccce1f256eaa9165a6b013b991a9bdf3886a8f2d23af50ee723a5614a9fe9d197252b803b4455a87ab2468e128f7b06e0ca@172.104.107.145:30303,enode://5a1fb15f826a213d3ef4adb9be47ab58b2240ea05df0d760a244f04762b0847dcb08276b1284f726c22eea30fce0c601cf121b81bac0c151f1b3b4ad00d1482a@34.159.55.147:51262,enode://560928dd14819f88113586726e452b16bbc694ed4144ddadd6290053e7f3fc66bfad13add6889f7d8f37e0c21ccbb6948eb8899c8b30743f4b45a3081f1efed8@34.138.254.5:29888,enode://69a13b575b8c5278431409e9f7db36e7218667ae286bfb65a72dfec9201b2c5bbbe2797a1babbdf17a7bf7ca68fa3fbe1554612637eb1b2425fa975e1bccb54c@35.223.41.3:30303,enode://66158b31eecff939f220b291d2b448edbfe94f1d4c992d9395b5d476e55e54b5abd11d3ee44daf1e18ee27b910ef99cdf6f19775eb4820ebe4f77d7aa948e3b6@51.195.63.10:55198,enode://bf94acbd51170bf075cacb9f149b21ff46354d659ab434a0d40688f776e1e1556bc62be2dc2867ba513844268c0dc8240099a6b60efe1713fbc25da7fdeb6ff1@3.82.105.139:30303,enode://41329e5ceb51cdddbe6a475db00b682505768b71ff8ee37d2d3500ca1b78918f9fad57d6006dd9f79cd418437dbcf87ec2fd58d60710f925cb17da05a51197cf@65.21.34.60:30303"
    ];
  };

  services.ethereum.geth.goerli = {
    enable = true;
    # More options ...
  };
}
```

**Note:** It is recommended to use an attribute name that matches the network that Geth is configured for.

## Configuration

Many of Geth's process arguments have been mapped to NixOS types and can be provided via the `args` section of the config.
For a detailed list please refer to the [NixOS Options](../reference/module-options/geth.md) reference.

Additional arguments can be provided in a list directly to the Geth process via the `extraArgs` attribute as shown above.

## Systemd service

For each instance that is configured a corresponding [Systemd](https://systemd.io/) service is created. The service name
follows a convention of `geth-${name}.service`.

| Config                           | Name    | Service name           |
| :------------------------------- | :------ | :--------------------- |
| `services.ethereum.geth.sepolia` | sepolia | `geth-sepolia.service` |
| `services.ethereum.geth.goerli`  | goerli  | `geth-goerli.service`  |
| `services.ethereum.geth.mainnet` | mainnet | `geth-mainnet.service` |

The service that is created can then be introspected and managed via the standard Systemd toolset.

| Action  | Command                                  |
| :------ | :--------------------------------------- |
| Status  | `systemctl status geth-sepolia.service`  |
| Stop    | `systemctl stop geth-sepolia.service`    |
| Start   | `systemctl start geth-sepolia.service`   |
| Restart | `systemctl restart geth-sepolia.service` |
| Logs    | `journalctl -xefu geth-sepolia.service`  |

## Using a Geth fork

A different version of Geth can be configured via the [package](../reference/module-options/geth.md#servicesethereumgethnamepackage) option.

To configure [Geth Sealer](https://github.com/manifoldfinance/geth-sealer) for example:

```nix title="server.nix"
{pkgs, ...}: {
  services.ethereum.geth.sepolia = {
    enable = true;
    package = pkgs.geth-sealer;
    # More options ...
  };
}
```

## Opening ports

By default, [openFirewall](../reference/module-options/geth.md#servicesethereumgethnameopenfirewall) is set to `false`.
If set to `true`, firewall rules are added which will expose the following ports:

| Protocol | Config                                                                                      | Default value |
| :------- | :------------------------------------------------------------------------------------------ | :------------ |
| TCP, UDP | [port](../reference/module-options/geth.md#servicesethereumgethnameargsport)                | 30303         |
| TCP      | [authrpc.port](../reference/module-options/geth.md#servicesethereumgethnameargsauthrpcport) | 8551          |
| TCP      | [http.port](../reference/module-options/geth.md#servicesethereumgethnameargshttpport)       | 8545          |
| TCP      | [ws.port](../reference/module-options/geth.md#servicesethereumgethnameargswsport)           | 8546          |
| TCP      | [metrics.port](../reference/module-options/geth.md#servicesethereumgethnameargsmetricsport) | 6060          |

**Note:** it is important when running multiple instances of Geth on the same machine that you ensure they are configured
with different ports.
