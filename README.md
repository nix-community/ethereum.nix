<div align="center" style="margin-top: 1em; margin-bottom: 3em;">
  <h1>Ethereum.nix = Ethereum 🫶 Nix</h1>
</div>

<p align="center">
  <a href="https://ethereum.org/">
    <img src="https://img.shields.io/static/v1?label=&labelColor=1B1E36&color=1B1E36&message=ethereum%20ecosystem&style=for-the-badge&logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiB2aWV3Qm94PSIwIDAgNDAgNDAiIGZpbGw9Im5vbmUiIHZlcnNpb249IjEuMiIgYmFzZVByb2ZpbGU9InRpbnktcHMiPjx0aXRsZT5FdGhlcmV1bSBsb2dvPC90aXRsZT48cGF0aCBkPSJNOSAyMi4xMTZMMTkuOTk5OSAyOS4wNDI0VjM4LjAwMDIiIGZpbGw9IiM1M0QzRTAiPjwvcGF0aD48cGF0aCBkPSJNMzAuOTk5OSAyMi4xMTZMMjAgMjkuMDQyNFYzOC4wMDAyIiBmaWxsPSIjNUE5REVEIj48L3BhdGg+PHBhdGggZD0iTTkgMTkuODc3NUwxOS45OTk5IDEzLjY5ODVWMUw5IDE5Ljg3NzVaIiBmaWxsPSIjRkZFOTREIj48L3BhdGg+PHBhdGggZD0iTTE5Ljk5OTkgMjYuODAzOVYxMy42OTg1TDkgMTkuODc3NUwxOS45OTk5IDI2LjgwMzlaIiBmaWxsPSIjQTdERjdFIj48L3BhdGg+PHBhdGggZD0iTTIwIDFWMTMuNjk4NUwzMC45OTk5IDE5Ljg3NzVMMjAgMVoiIGZpbGw9IiNGRjlDOTIiPjwvcGF0aD48cGF0aCBkPSJNMjAgMTMuNjk4NVYyNi44MDM5TDMwLjk5OTkgMTkuODc3NUwyMCAxMy42OTg1WiIgZmlsbD0iI0Q3OTdEMSI+PC9wYXRoPjwvc3ZnPg==" alt="Ethereum Ecosystem"/>
  </a>
  <a href="https://nixos.org/">
    <img src="https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a&style=for-the-badge" alt="Built with nix" />
  </a>
  <a href="https://github.com/nix-community/ethereum.nix/blob/main/LICENSE.md">
    <img src="https://img.shields.io/badge/license-MIT%20v3.0-brightgreen.svg?style=for-the-badge" alt="License" />
  </a>
</p>

Ethereum.nix is a collection of [Nix](https://nixos.org) packages and [NixOS](https://wiki.nixos.org/wiki/NixOS_modules) modules
designed to make it easier to operate [Ethereum](https://ethereum.org) related services and infrastructure.

For the uninitiated, using Ethereum.nix will give you the following benefits:

- Access to a wide range of Ethereum applications packaged with Nix, ready to run without fuss. Nix guarantees you don't have to worry about version conflicts, missing dependencies or even what state your OS is in.
- We aim that every Ethereum application stored in the repository is constructed from its source, including all input dependencies. This approach guarantees the code's reproducibility and trustworthiness. Furthermore, with Nix, expert users can tweak and adjust the build process to any degree of detail as required.
- We develop custom NixOS modules to streamline operations with applications such as Execution and Consensus clients (including performing backups). Moreover, we aim to introduce further abstractions that simplify everyday tasks, such as running a development environment effortlessly without needing docker.

This project is developed entirely in [Nix Flakes](https://wiki.nixos.org/wiki/Flakes) (but it offers compatibility with legacy Nix thanks to [`flake-compat`](https://github.com/nix-community/flake-compat)).

## Available Tools

<!-- `> ./bin/update-readme.sh` -->

<!-- BEGIN mdsh -->
#### ackee-blockchain.solidity-tools

- **Description**: No description available
- **Version**: unknown
- **Source**: unknown
- **License**: Check package
- **Usage**: `nix run .#ackee-blockchain.solidity-tools -- --help`

#### besu

- **Description**: Besu is an Apache 2.0 licensed, MainNet compatible, Ethereum client written in Java
- **Version**: 25.7.0
- **Source**: bytecode
- **License**: Apache-2.0
- **Homepage**: https://github.com/hyperledger/besu
- **Usage**: `nix run .#besu -- --help`

#### bls

- **Description**: BLS threshold signature
- **Version**: 1.86
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/herumi/bls
- **Usage**: `nix run .#bls -- --help`

#### blst

- **Description**: Multilingual BLS12-381 signature library
- **Version**: 0.3.11
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/supranational/blst
- **Usage**: `nix run .#blst -- --help`

#### blutgang

- **Description**: the wd40 of ethereum load balancers
- **Version**: 0.3.6
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/rainshowerLabs/blutgang
- **Usage**: `nix run .#blutgang -- --help`

#### charon

- **Description**: Charon (pronounced 'kharon') is a Proof of Stake Ethereum Distributed Validator Client
- **Version**: 0.19.1
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/ObolNetwork/charon
- **Usage**: `nix run .#charon -- --help`

#### ckzg

- **Description**: A minimal implementation of the Polynomial Commitments API
- **Version**: 2.1.1
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/ethereum/c-kzg-4844
- **Usage**: `nix run .#ckzg -- --help`

#### consensys.vscode-solidity-auditor

- **Description**: No description available
- **Version**: unknown
- **Source**: unknown
- **License**: Check package
- **Usage**: `nix run .#consensys.vscode-solidity-auditor -- --help`

#### dirk

- **Description**: An Ethereum 2 distributed remote keymanager, focused on security and long-term performance of signing operations
- **Version**: 1.2.0
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/attestantio/dirk
- **Usage**: `nix run .#dirk -- --help`

#### dreamboat

- **Description**: An Ethereum 2.0 Relay for proposer-builder separation (PBS) with MEV-boost
- **Version**: 0.6.3
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/blocknative/dreamboat
- **Usage**: `nix run .#dreamboat -- --help`

#### eigenlayer

- **Description**: Utility manages core operator functionalities like local key management, operator registration and updates
- **Version**: 0.6.2
- **Source**: unknown
- **License**: BUSL-1.1
- **Homepage**: https://www.eigenlayer.xyz/
- **Usage**: `nix run .#eigenlayer -- --help`

#### erigon

- **Description**: Ethereum node implementation focused on scalability and modularity
- **Version**: 3.0.15
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/erigontech/erigon/
- **Usage**: `nix run .#erigon -- --help`

#### eth-validator-watcher

- **Description**: Ethereum validator monitor
- **Version**: 1.0.0
- **Source**: unknown
- **License**: MIT
- **Homepage**: https://github.com/kilnfi/eth-validator-watcher
- **Usage**: `nix run .#eth-validator-watcher -- --help`

#### eth2-testnet-genesis

- **Description**: Create a genesis state for an Eth2 testnet
- **Version**: 0.9.0
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/protolambda/eth2-testnet-genesis
- **Usage**: `nix run .#eth2-testnet-genesis -- --help`

#### eth2-val-tools

- **Description**: Some experimental tools to manage validators
- **Version**: 0.1.1
- **Source**: unknown
- **License**: MIT
- **Homepage**: https://github.com/protolambda/eth2-val-tools
- **Usage**: `nix run .#eth2-val-tools -- --help`

#### ethdo

- **Description**: A command-line tool for managing common tasks in Ethereum 2
- **Version**: 1.38.0
- **Source**: unknown
- **License**: APSL-2.0
- **Homepage**: https://github.com/wealdtech/ethdo
- **Usage**: `nix run .#ethdo -- --help`

#### ethereal

- **Description**: A command-line tool for managing common tasks in Ethereum
- **Version**: 2.9.0
- **Source**: unknown
- **License**: APSL-2.0
- **Homepage**: https://github.com/wealdtech/ethereal/
- **Usage**: `nix run .#ethereal -- --help`

#### ethstaker-deposit-cli

- **Description**: Secure key generation for deposits (ethstaker fork)
- **Version**: 1.2.2
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/ethstaker/ethstaker-deposit-cli/
- **Usage**: `nix run .#ethstaker-deposit-cli -- --help`

#### evmc

- **Description**: EVMC – Ethereum Client-VM Connector API
- **Version**: 10.0.0
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/ethereum/evmc
- **Usage**: `nix run .#evmc -- --help`

#### foundry

- **Description**: A portable, modular toolkit for Ethereum application development written in Rust.
- **Version**: 1.3.0
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/foundry-rs/foundry
- **Usage**: `nix run .#foundry -- --help`

#### geth

- **Description**: Official golang implementation of the Ethereum protocol
- **Version**: 1.16.2
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://geth.ethereum.org/
- **Usage**: `nix run .#geth -- --help`

#### heimdall

- **Description**: A toolkit for EVM bytecode analysis
- **Version**: 0.8.7
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://heimdall.rs
- **Usage**: `nix run .#heimdall -- --help`

#### lighthouse

- **Description**: Ethereum consensus client in Rust
- **Version**: 7.1.0
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/sigp/lighthouse
- **Usage**: `nix run .#lighthouse -- --help`

#### mcl

- **Description**: A portable and fast pairing-based cryptography library
- **Version**: 1.81
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/herumi/mcl
- **Usage**: `nix run .#mcl -- --help`

#### mev-boost

- **Description**: MEV-Boost allows proof-of-stake Ethereum consensus clients to source blocks from a competitive builder marketplace
- **Version**: 1.9.0
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/flashbots/mev-boost
- **Usage**: `nix run .#mev-boost -- --help`

#### mev-boost-relay

- **Description**: MEV-Boost Relay for Ethereum proposer/builder separation (PBS)
- **Version**: 0.29.1
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/flashbots/mev-boost-relay
- **Usage**: `nix run .#mev-boost-relay -- --help`

#### mev-rs

- **Description**: A gateway to a network of block builders
- **Version**: 0.3.0
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/ralexstokes/mev-rs
- **Usage**: `nix run .#mev-rs -- --help`

#### nethermind

- **Description**: Our flagship Ethereum client for Linux, Windows, and macOS—full and actively developed
- **Version**: 1.32.4
- **Source**: unknown
- **License**: GPL-3.0
- **Homepage**: https://nethermind.io/nethermind-client
- **Usage**: `nix run .#nethermind -- --help`

#### nimbus

- **Description**: Nimbus is a lightweight client for the Ethereum consensus layer
- **Version**: 25.7.1-unknown
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://nimbus.guide/
- **Usage**: `nix run .#nimbus -- --help`

#### prysm

- **Description**: Go implementation of Ethereum proof of stake
- **Version**: 6.0.4
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/prysmaticlabs/prysm
- **Usage**: `nix run .#prysm -- --help`

#### reth

- **Description**: Modular, contributor-friendly and blazing-fast implementation of the Ethereum protocol, in Rust
- **Version**: 1.6.0
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/paradigmxyz/reth
- **Usage**: `nix run .#reth -- --help`

#### rocketpool

- **Description**: Rocket Pool CLI
- **Version**: 1.17.2
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/rocket-pool/smartnode
- **Usage**: `nix run .#rocketpool -- --help`

#### rocketpoold

- **Description**: Rocket Pool Daemon
- **Version**: 1.17.2
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/rocket-pool/smartnode
- **Usage**: `nix run .#rocketpoold -- --help`

#### rotki-bin

- **Description**: An open source portfolio tracking tool that respects your privacy
- **Version**: 1.40.0
- **Source**: binary
- **License**: AGPL-3.0-or-later
- **Homepage**: https://rotki.com/
- **Usage**: `nix run .#rotki-bin -- --help`

#### sedge

- **Description**: A one-click setup tool for PoS network/chain validators and nodes.
- **Version**: 1.9.1
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://docs.sedge.nethermind.io/
- **Usage**: `nix run .#sedge -- --help`

#### slither

- **Description**: Static Analyzer for Solidity
- **Version**: 0.10.0
- **Source**: unknown
- **License**: AGPL-3.0-only
- **Homepage**: https://github.com/crytic/slither
- **Usage**: `nix run .#slither -- --help`

#### snarkjs

- **Description**: zkSNARK implementation in JavaScript & WASM
- **Version**: 0.7.3
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/iden3/snarkjs
- **Usage**: `nix run .#snarkjs -- --help`

#### ssv-dkg

- **Description**: The ssv-dkg tool enable operators to participate in ceremonies to generate distributed validator keys for Ethereum stakers.
- **Version**: 3.0.3
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/ssvlabs/ssv-dkg
- **Usage**: `nix run .#ssv-dkg -- --help`

#### ssvnode

- **Description**: Secret-Shared-Validator(SSV) for ethereum staking
- **Version**: 2.0.0
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/ssvlabs/ssv
- **Usage**: `nix run .#ssvnode -- --help`

#### staking-deposit-cli

- **Description**: Secure key generation for deposits
- **Version**: 2.8.0
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/ethereum/staking-deposit-cli
- **Usage**: `nix run .#staking-deposit-cli -- --help`

#### teku

- **Description**: Java Implementation of the Ethereum 2.0 Beacon Chain
- **Version**: 25.7.1
- **Source**: bytecode
- **License**: Apache-2.0
- **Homepage**: https://github.com/ConsenSys/teku
- **Usage**: `nix run .#teku -- --help`

#### tx-fuzz

- **Description**: TX-Fuzz is a package containing helpful functions to create random transactions
- **Version**: 1.3.2
- **Source**: unknown
- **License**: MIT
- **Homepage**: https://github.com/MariusVanDerWijden/tx-fuzz
- **Usage**: `nix run .#tx-fuzz -- --help`

#### vouch

- **Description**: An Ethereum 2 multi-node validator client
- **Version**: 1.11.1
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/attestantio/vouch
- **Usage**: `nix run .#vouch -- --help`

#### web3signer

- **Description**: Web3Signer is an open-source signing service capable of signing on multiple platforms (Ethereum1 and 2, Filecoin) using private keys stored in an external vault, or encrypted on a disk
- **Version**: 25.4.1
- **Source**: bytecode
- **License**: APSL-2.0
- **Homepage**: https://github.com/ConsenSys/web3signer
- **Usage**: `nix run .#web3signer -- --help`

#### zcli

- **Description**: Eth2 CLI debugging tool
- **Version**: 0.7.1
- **Source**: unknown
- **License**: Check package
- **Homepage**: https://github.com/protolambda/zcli
- **Usage**: `nix run .#zcli -- --help`

<!-- END mdsh -->

## Development

We use [`devshell`](https://github.com/numtide/devshell) to have nice development environments. Below you can find the list of available commands:

```bash
🔨 Welcome to ethereum.nix

[Docs]

  docs  - Build and watch for docs

[Testing]

  tests - Build and run a test

[Tools]

  check - Checks the source tree
  fmt   - Format the source tree

[general commands]

  menu  - prints this menu

```

### Requirements

To make the most of this repository, you should have the following installed:

- [Nix](https://nixos.org/)
- [Direnv](https://direnv.net/)

After cloning this repository and entering inside, run `direnv allow` when prompted, and you will be met with the previous prompt.

### Docs

To build the docs locally, run `docs build`. The output will be inside of `./result`.

Run `docs serve` to serve the docs locally (after building them previously). You can edit the docs in `./docs`.

### Running tests

To run all tests, you can use `check` (alias for `nix flake check`); it will build all packages and run all tests.

You can use `tests -h` to execute a specific test, which will provide more information.

### Formatting

You can manually format the source using the `fmt` command.

## Contribute

We welcome any contribution or support to this project, but before doing so:

- Make sure you have read the [contribution guide](/.github/CONTRIBUTING.md) for more details on how to submit a good PR (pull request).

In addition, you can always:

- Add a [GitHub Star 🌟](https://github.com/nix-community/ethereum.nix/stargazers) to the project.
- Tweet about this project.

## Acknowledgements

This project has been inspired by the awesome work of:

- [`cosmos.nix`](https://github.com/informalsystems/cosmos.nix) by [Informal Systems](https://github.com/informalsystems), which this repository takes inspiration from its README and several other places.

- [willruggiano](https://github.com/willruggiano) on his work done in [`eth-nix`](https://github.com/willruggiano/eth-nix) repository that served as the initial kick-start for working on this project.
