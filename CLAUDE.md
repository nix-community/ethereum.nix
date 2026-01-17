# ethereum.nix

Reproducible Nix package set for Ethereum clients and utilities.

## Project Structure

```
pkgs/
├── default.nix              # package definitions + overlay
└── by-name/
    └── <package>/
        └── default.nix      # individual package derivation

modules/
├── <client>/
│   ├── default.nix      # systemd service implementation
│   ├── options.nix      # NixOS module options
│   └── default.test.nix # NixOS VM test
├── lib.nix              # shared utilities (baseServiceConfig)
└── testing.nix          # test discovery framework
```

## Packages (44 total)

**Execution Layer:** geth, reth, erigon, besu, nethermind

**Consensus Layer:** lighthouse, prysm, nimbus, teku

**MEV:** mev-boost, mev-boost-relay

**Validators & Key Management:** dirk, vouch, web3signer, ethdo, eth2-val-tools, staking-deposit-cli, ethstaker-deposit-cli

**SSV (Distributed Validators):** ssvnode, ssv-dkg, charon

**Development Tools:** foundry, foundry-bin, slither, solidity-language-server, snarkjs, evmc, tx-fuzz, kurtosis, sedge

**Utilities:** eigenlayer, ethereal, rocketpool, rocketpoold, heimdall, zcli, blutgang, eth-validator-watcher, rotki-bin, eth2-testnet-genesis

**Crypto Libraries:** bls, blst, mcl, ckzg

## RFC 42 Settings Pattern

All modules use RFC 42 `settings` pattern with `freeformType`:

```nix
services.ethereum.geth.mainnet = {
  enable = true;
  settings = {
    http = true;
    "http.addr" = "0.0.0.0";
    "http.api" = ["eth" "net" "web3"];
    sepolia = true;
  };
  extraArgs = ["--custom-flag"];
};
```

Key points:

- Use flat dotted keys: `"http.addr"` not `http.addr`
- Unknown options pass through via `freeformType`
- `extraArgs` for flags not covered by settings

## Using `lib.cli` for CLI Arguments

Modules use `lib.cli.toCommandLine` to convert settings to CLI args:

| CLI Style | Function |
|-----------|----------|
| `-flag value` | `toCommandLine` with `option = "-${name}"` |
| `--flag value` | `toCommandLine` with `option = "--${name}"` |
| `--flag=value` | `toCommandLine` with `sep = "="` |
| GNU-style | `toCommandLineGNU` |

## Testing

### Test file format

Each module can have `default.test.nix`:

```nix
{
  systems = ["x86_64-linux"];

  module = {
    name = "example";

    nodes = {
      basic = {
        services.ethereum.example.test = {
          enable = true;
          settings = {
            network = "sepolia";
          };
        };
      };
    };

    testScript = ''
      basic.wait_for_unit("example-test.service")
      basic.sleep(10)
      basic.succeed("systemctl is-active example-test.service")
    '';
  };
}
```

### Running tests

```bash
# Build and run test
nix build .#checks.x86_64-linux.testing-geth-default

# Interactive mode
nix build .#checks.x86_64-linux.testing-geth-default.driver
./result/bin/nixos-test-driver --interactive

# List available tests
nix eval .#checks.x86_64-linux --apply 'x: builtins.filter (n: builtins.substring 0 8 n == "testing-") (builtins.attrNames x)'
```

### Available tests

- `testing-geth-default`
- `testing-reth-default`
- `testing-erigon-default`
- `testing-besu-default`
- `testing-nethermind-default`
- `testing-prysm-default`
- `testing-lighthouse-default`
- `testing-nimbus-default`
- `testing-teku-default`
- `testing-mev-boost-default`
- `testing-prysm-validator-default`

## References

- [RFC 42: NixOS settings options](https://github.com/NixOS/rfcs/blob/master/rfcs/0042-config-option.md)
- [Discussion #325: Module System Consideration](https://github.com/nix-community/ethereum.nix/discussions/325)
