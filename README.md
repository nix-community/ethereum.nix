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

This project is developed entirely in [Nix Flakes](https://wiki.nixos.org/wiki/Flakes).

## Available Tools

<!-- BEGIN GENERATED PACKAGE DOCS -->

### Execution Clients

<details>
<summary><strong>besu</strong> - Besu is an Apache 2.0 licensed, MainNet compatible, Ethereum client written in Java</summary>

- **Source**: bytecode
- **License**: Apache-2.0
- **Homepage**: https://github.com/hyperledger/besu
- **Usage**: `nix run github:nix-community/ethereum.nix#besu -- --help`
- **Nix**: [packages/besu/package.nix](packages/besu/package.nix)

</details>
<details>
<summary><strong>erigon</strong> - Ethereum node implementation focused on scalability and modularity</summary>

- **Source**: source
- **License**: LGPL-3.0-only
- **Homepage**: https://github.com/erigontech/erigon/
- **Usage**: `nix run github:nix-community/ethereum.nix#erigon -- --help`
- **Nix**: [packages/erigon/package.nix](packages/erigon/package.nix)

</details>
<details>
<summary><strong>ethrex</strong> - Modular and ZK-native Ethereum execution client written in Rust</summary>

- **Source**: source
- **License**: Check package
- **Homepage**: https://github.com/lambdaclass/ethrex
- **Usage**: `nix run github:nix-community/ethereum.nix#ethrex -- --help`
- **Nix**: [packages/ethrex/package.nix](packages/ethrex/package.nix)

</details>
<details>
<summary><strong>geth</strong> - Official golang implementation of the Ethereum protocol</summary>

- **Source**: source
- **License**: Check package
- **Homepage**: https://geth.ethereum.org/
- **Usage**: `nix run github:nix-community/ethereum.nix#geth -- --help`
- **Nix**: [packages/geth/package.nix](packages/geth/package.nix)

</details>
<details>
<summary><strong>nethermind</strong> - Our flagship Ethereum client for Linux, Windows, and macOS—full and actively developed</summary>

- **Source**: source
- **License**: GPL-3.0
- **Homepage**: https://nethermind.io/nethermind-client
- **Usage**: `nix run github:nix-community/ethereum.nix#nethermind -- --help`
- **Nix**: [packages/nethermind/package.nix](packages/nethermind/package.nix)

</details>
<details>
<summary><strong>reth</strong> - Modular, contributor-friendly and blazing-fast implementation of the Ethereum protocol, in Rust</summary>

- **Source**: source
- **License**: Check package
- **Homepage**: https://github.com/paradigmxyz/reth
- **Usage**: `nix run github:nix-community/ethereum.nix#reth -- --help`
- **Nix**: [packages/reth/package.nix](packages/reth/package.nix)

</details>

### Consensus Clients

<details>
<summary><strong>grandine</strong> - High performance Ethereum consensus client</summary>

- **Source**: binary
- **License**: GPL-3.0-only
- **Homepage**: https://github.com/grandinetech/grandine
- **Usage**: `nix run github:nix-community/ethereum.nix#grandine -- --help`
- **Nix**: [packages/grandine/package.nix](packages/grandine/package.nix)

</details>
<details>
<summary><strong>lighthouse</strong> - Ethereum consensus client in Rust</summary>

- **Source**: source
- **License**: Apache-2.0
- **Homepage**: https://github.com/sigp/lighthouse
- **Usage**: `nix run github:nix-community/ethereum.nix#lighthouse -- --help`
- **Nix**: [packages/lighthouse/package.nix](packages/lighthouse/package.nix)

</details>
<details>
<summary><strong>lodestar</strong> - TypeScript implementation of the Ethereum consensus specification</summary>

- **Source**: binary
- **License**: Apache-2.0
- **Homepage**: https://lodestar.chainsafe.io
- **Usage**: `nix run github:nix-community/ethereum.nix#lodestar -- --help`
- **Nix**: [packages/lodestar/package.nix](packages/lodestar/package.nix)

</details>
<details>
<summary><strong>prysm</strong> - Go implementation of Ethereum proof of stake</summary>

- **Source**: source
- **License**: GPL-3.0-only
- **Homepage**: https://github.com/prysmaticlabs/prysm
- **Usage**: `nix run github:nix-community/ethereum.nix#prysm -- --help`
- **Nix**: [packages/prysm/package.nix](packages/prysm/package.nix)

</details>
<details>
<summary><strong>teku</strong> - Java Implementation of the Ethereum 2.0 Beacon Chain</summary>

- **Source**: bytecode
- **License**: Apache-2.0
- **Homepage**: https://github.com/ConsenSys/teku
- **Usage**: `nix run github:nix-community/ethereum.nix#teku -- --help`
- **Nix**: [packages/teku/package.nix](packages/teku/package.nix)

</details>

### Validators

<details>
<summary><strong>charon</strong> - Charon (pronounced 'kharon') is a Proof of Stake Ethereum Distributed Validator Client</summary>

- **Source**: source
- **License**: BUSL-1.1
- **Homepage**: https://github.com/ObolNetwork/charon
- **Usage**: `nix run github:nix-community/ethereum.nix#charon -- --help`
- **Nix**: [packages/charon/package.nix](packages/charon/package.nix)

</details>
<details>
<summary><strong>dirk</strong> - An Ethereum 2 distributed remote keymanager, focused on security and long-term performance of signing operations</summary>

- **Source**: source
- **License**: Apache-2.0
- **Homepage**: https://github.com/attestantio/dirk
- **Usage**: `nix run github:nix-community/ethereum.nix#dirk -- --help`
- **Nix**: [packages/dirk/package.nix](packages/dirk/package.nix)

</details>
<details>
<summary><strong>vouch</strong> - An Ethereum 2 multi-node validator client</summary>

- **Source**: source
- **License**: Apache-2.0
- **Homepage**: https://github.com/attestantio/vouch
- **Usage**: `nix run github:nix-community/ethereum.nix#vouch -- --help`
- **Nix**: [packages/vouch/package.nix](packages/vouch/package.nix)

</details>
<details>
<summary><strong>web3signer</strong> - Web3Signer is an open-source signing service capable of signing on multiple platforms (Ethereum1 and 2, Filecoin) using private keys stored in an external vault, or encrypted on a disk</summary>

- **Source**: bytecode
- **License**: APSL-2.0
- **Homepage**: https://github.com/ConsenSys/web3signer
- **Usage**: `nix run github:nix-community/ethereum.nix#web3signer -- --help`
- **Nix**: [packages/web3signer/package.nix](packages/web3signer/package.nix)

</details>

### MEV

<details>
<summary><strong>mev-boost</strong> - MEV-Boost allows proof-of-stake Ethereum consensus clients to source blocks from a competitive builder marketplace</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/flashbots/mev-boost
- **Usage**: `nix run github:nix-community/ethereum.nix#mev-boost -- --help`
- **Nix**: [packages/mev-boost/package.nix](packages/mev-boost/package.nix)

</details>
<details>
<summary><strong>mev-boost-relay</strong> - MEV-Boost Relay for Ethereum proposer/builder separation (PBS)</summary>

- **Source**: source
- **License**: AGPL-3.0-only
- **Homepage**: https://github.com/flashbots/mev-boost-relay
- **Usage**: `nix run github:nix-community/ethereum.nix#mev-boost-relay -- --help`
- **Nix**: [packages/mev-boost-relay/package.nix](packages/mev-boost-relay/package.nix)

</details>

### SSV

<details>
<summary><strong>ssv-dkg</strong> - The ssv-dkg tool enable operators to participate in ceremonies to generate distributed validator keys for Ethereum stakers.</summary>

- **Source**: source
- **License**: Check package
- **Homepage**: https://github.com/ssvlabs/ssv-dkg
- **Usage**: `nix run github:nix-community/ethereum.nix#ssv-dkg -- --help`
- **Nix**: [packages/ssv-dkg/package.nix](packages/ssv-dkg/package.nix)

</details>
<details>
<summary><strong>ssvnode</strong> - Secret-Shared-Validator(SSV) for ethereum staking</summary>

- **Source**: source
- **License**: GPL-3.0-only
- **Homepage**: https://github.com/ssvlabs/ssv
- **Usage**: `nix run github:nix-community/ethereum.nix#ssvnode -- --help`
- **Nix**: [packages/ssvnode/package.nix](packages/ssvnode/package.nix)

</details>

### Account Abstraction

<details>
<summary><strong>alto</strong> - A performant, reliable, and type-safe ERC-4337 Bundler written in TypeScript</summary>

- **Source**: source
- **License**: GPL-3.0-only
- **Homepage**: https://github.com/pimlicolabs/alto
- **Usage**: `nix run github:nix-community/ethereum.nix#alto -- --help`
- **Nix**: [packages/alto/package.nix](packages/alto/package.nix)

</details>

### Polygon

<details>
<summary><strong>bor</strong> - Official execution client of the Polygon blockchain</summary>

- **Source**: source
- **License**: LGPL-3.0-only
- **Homepage**: https://github.com/maticnetwork/bor
- **Usage**: `nix run github:nix-community/ethereum.nix#bor -- --help`
- **Nix**: [packages/bor/package.nix](packages/bor/package.nix)

</details>
<details>
<summary><strong>heimdall-v2</strong> - Official consensus client of the Polygon blockchain</summary>

- **Source**: source
- **License**: GPL-3.0-only
- **Homepage**: https://github.com/0xPolygon/heimdall-v2
- **Usage**: `nix run github:nix-community/ethereum.nix#heimdall-v2 -- --help`
- **Nix**: [packages/heimdall-v2/package.nix](packages/heimdall-v2/package.nix)

</details>

### Development Tools

<details>
<summary><strong>eth2-testnet-genesis</strong> - Create a genesis state for an Eth2 testnet</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/protolambda/eth2-testnet-genesis
- **Usage**: `nix run github:nix-community/ethereum.nix#eth2-testnet-genesis -- --help`
- **Nix**: [packages/eth2-testnet-genesis/package.nix](packages/eth2-testnet-genesis/package.nix)

</details>
<details>
<summary><strong>eth2-val-tools</strong> - Some experimental tools to manage validators</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/protolambda/eth2-val-tools
- **Usage**: `nix run github:nix-community/ethereum.nix#eth2-val-tools -- --help`
- **Nix**: [packages/eth2-val-tools/package.nix](packages/eth2-val-tools/package.nix)

</details>
<details>
<summary><strong>ethabi</strong> - Encode and decode smart contract invocations</summary>

- **Source**: source
- **License**: Apache-2.0
- **Homepage**: https://github.com/rust-ethereum/ethabi
- **Usage**: `nix run github:nix-community/ethereum.nix#ethabi -- --help`
- **Nix**: [packages/ethabi/package.nix](packages/ethabi/package.nix)

</details>
<details>
<summary><strong>ethdo</strong> - A command-line tool for managing common tasks in Ethereum 2</summary>

- **Source**: source
- **License**: APSL-2.0
- **Homepage**: https://github.com/wealdtech/ethdo
- **Usage**: `nix run github:nix-community/ethereum.nix#ethdo -- --help`
- **Nix**: [packages/ethdo/package.nix](packages/ethdo/package.nix)

</details>
<details>
<summary><strong>ethereal</strong> - A command-line tool for managing common tasks in Ethereum</summary>

- **Source**: source
- **License**: APSL-2.0
- **Homepage**: https://github.com/wealdtech/ethereal/
- **Usage**: `nix run github:nix-community/ethereum.nix#ethereal -- --help`
- **Nix**: [packages/ethereal/package.nix](packages/ethereal/package.nix)

</details>
<details>
<summary><strong>heimdall</strong> - A toolkit for EVM bytecode analysis</summary>

- **Source**: source
- **License**: Check package
- **Homepage**: https://heimdall.rs
- **Usage**: `nix run github:nix-community/ethereum.nix#heimdall -- --help`
- **Nix**: [packages/heimdall/package.nix](packages/heimdall/package.nix)

</details>
<details>
<summary><strong>kurtosis</strong> - CLI for Kurtosis, a framework for building and running distributed systems</summary>

- **Source**: binary
- **License**: Apache-2.0
- **Homepage**: https://github.com/kurtosis-tech/kurtosis
- **Usage**: `nix run github:nix-community/ethereum.nix#kurtosis -- --help`
- **Nix**: [packages/kurtosis/package.nix](packages/kurtosis/package.nix)

</details>
<details>
<summary><strong>sedge</strong> - A one-click setup tool for PoS network/chain validators and nodes.</summary>

- **Source**: source
- **License**: Apache-2.0
- **Homepage**: https://docs.sedge.nethermind.io/
- **Usage**: `nix run github:nix-community/ethereum.nix#sedge -- --help`
- **Nix**: [packages/sedge/package.nix](packages/sedge/package.nix)

</details>
<details>
<summary><strong>tx-fuzz</strong> - TX-Fuzz is a package containing helpful functions to create random transactions</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/MariusVanDerWijden/tx-fuzz
- **Usage**: `nix run github:nix-community/ethereum.nix#tx-fuzz -- --help`
- **Nix**: [packages/tx-fuzz/package.nix](packages/tx-fuzz/package.nix)

</details>
<details>
<summary><strong>zcli</strong> - Eth2 CLI debugging tool</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/protolambda/zcli
- **Usage**: `nix run github:nix-community/ethereum.nix#zcli -- --help`
- **Nix**: [packages/zcli/package.nix](packages/zcli/package.nix)

</details>

### Utilities

<details>
<summary><strong>blutgang</strong> - the wd40 of ethereum load balancers</summary>

- **Source**: source
- **License**: GPL-2.0-only
- **Homepage**: https://github.com/rainshowerLabs/blutgang
- **Usage**: `nix run github:nix-community/ethereum.nix#blutgang -- --help`
- **Nix**: [packages/blutgang/package.nix](packages/blutgang/package.nix)

</details>
<details>
<summary><strong>checkpointz</strong> - Ethereum beacon chain checkpoint sync provider</summary>

- **Source**: source
- **License**: GPL-3.0-only
- **Homepage**: https://github.com/ethpandaops/checkpointz
- **Usage**: `nix run github:nix-community/ethereum.nix#checkpointz -- --help`
- **Nix**: [packages/checkpointz/package.nix](packages/checkpointz/package.nix)

</details>
<details>
<summary><strong>dora</strong> - Lightweight beaconchain explorer for Ethereum</summary>

- **Source**: source
- **License**: GPL-3.0-only
- **Homepage**: https://github.com/ethpandaops/dora
- **Usage**: `nix run github:nix-community/ethereum.nix#dora -- --help`
- **Nix**: [packages/dora/package.nix](packages/dora/package.nix)

</details>
<details>
<summary><strong>rotki-bin</strong> - An open source portfolio tracking tool that respects your privacy</summary>

- **Source**: binary
- **License**: AGPL-3.0-or-later
- **Homepage**: https://rotki.com/
- **Usage**: `nix run github:nix-community/ethereum.nix#rotki-bin -- --help`
- **Nix**: [packages/rotki-bin/package.nix](packages/rotki-bin/package.nix)

</details>
<details>
<summary><strong>tracoor</strong> - Ethereum beacon data and execution trace explorer</summary>

- **Source**: source
- **License**: GPL-3.0-only
- **Homepage**: https://github.com/ethpandaops/tracoor
- **Usage**: `nix run github:nix-community/ethereum.nix#tracoor -- --help`
- **Nix**: [packages/tracoor/package.nix](packages/tracoor/package.nix)

</details>

### Uncategorized

<details>
<summary><strong>formatter</strong> - One CLI to format the code tree</summary>

- **Source**: unknown
- **License**: MIT
- **Homepage**: https://github.com/numtide/treefmt
- **Usage**: `nix run github:nix-community/ethereum.nix#formatter -- --help`
- **Nix**: [packages/formatter/package.nix](packages/formatter/package.nix)

</details>
<details>
<summary><strong>nimbus</strong> - Nimbus is a lightweight client for the Ethereum consensus layer</summary>

- **Source**: unknown
- **License**: Check package
- **Homepage**: https://nimbus.guide/
- **Usage**: `nix run github:nix-community/ethereum.nix#nimbus -- --help`
- **Nix**: [packages/nimbus/package.nix](packages/nimbus/package.nix)

</details>

### Arbitrum

<details>
<summary><strong>nitro</strong> - Arbitrum Nitro node implementation for Ethereum Layer 2</summary>

- **Source**: source
- **License**: BUSL-1.1
- **Homepage**: https://github.com/OffchainLabs/nitro
- **Usage**: `nix run github:nix-community/ethereum.nix#nitro -- --help`
- **Nix**: [packages/nitro/package.nix](packages/nitro/package.nix)

</details>

### LSP

<details>
<summary><strong>solidity-language-server</strong> - Solidity language server by Nomic Foundation</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/NomicFoundation/hardhat-vscode
- **Usage**: `nix run github:nix-community/ethereum.nix#solidity-language-server -- --help`
- **Nix**: [packages/solidity-language-server/package.nix](packages/solidity-language-server/package.nix)

</details>

### Optimism

<details>
<summary><strong>op-batcher</strong> - Optimism batcher service that submits L2 transaction batches to L1</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/ethereum-optimism/optimism/tree/develop/op-batcher
- **Usage**: `nix run github:nix-community/ethereum.nix#op-batcher -- --help`
- **Nix**: [packages/op-batcher/package.nix](packages/op-batcher/package.nix)

</details>
<details>
<summary><strong>op-challenger</strong> - Optimism fault proof challenger service that monitors and disputes invalid claims</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/ethereum-optimism/optimism/tree/develop/op-challenger
- **Usage**: `nix run github:nix-community/ethereum.nix#op-challenger -- --help`
- **Nix**: [packages/op-challenger/package.nix](packages/op-challenger/package.nix)

</details>
<details>
<summary><strong>op-conductor</strong> - Optimism sequencer conductor for high-availability setups</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/ethereum-optimism/optimism/tree/develop/op-conductor
- **Usage**: `nix run github:nix-community/ethereum.nix#op-conductor -- --help`
- **Nix**: [packages/op-conductor/package.nix](packages/op-conductor/package.nix)

</details>
<details>
<summary><strong>op-deployer</strong> - Optimism deployer tool for deploying OP Stack chains</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/ethereum-optimism/optimism/tree/develop/op-deployer
- **Usage**: `nix run github:nix-community/ethereum.nix#op-deployer -- --help`
- **Nix**: [packages/op-deployer/package.nix](packages/op-deployer/package.nix)

</details>
<details>
<summary><strong>op-dispute-mon</strong> - Optimism dispute monitor that tracks and reports on fault proof disputes</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/ethereum-optimism/optimism/tree/develop/op-dispute-mon
- **Usage**: `nix run github:nix-community/ethereum.nix#op-dispute-mon -- --help`
- **Nix**: [packages/op-dispute-mon/package.nix](packages/op-dispute-mon/package.nix)

</details>
<details>
<summary><strong>op-geth</strong> - Optimism implementation of the Ethereum protocol</summary>

- **Source**: source
- **License**: Check package
- **Homepage**: https://github.com/ethereum-optimism/op-geth
- **Usage**: `nix run github:nix-community/ethereum.nix#op-geth -- --help`
- **Nix**: [packages/op-geth/package.nix](packages/op-geth/package.nix)

</details>
<details>
<summary><strong>op-node</strong> - Optimism rollup node that derives the L2 chain from L1</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/ethereum-optimism/optimism/tree/develop/op-node
- **Usage**: `nix run github:nix-community/ethereum.nix#op-node -- --help`
- **Nix**: [packages/op-node/package.nix](packages/op-node/package.nix)

</details>
<details>
<summary><strong>op-proposer</strong> - Optimism proposer service that submits L2 output proposals to L1</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/ethereum-optimism/optimism/tree/develop/op-proposer
- **Usage**: `nix run github:nix-community/ethereum.nix#op-proposer -- --help`
- **Nix**: [packages/op-proposer/package.nix](packages/op-proposer/package.nix)

</details>
<details>
<summary><strong>op-supervisor</strong> - Optimism supervisor for cross-chain message verification</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/ethereum-optimism/optimism/tree/develop/op-supervisor
- **Usage**: `nix run github:nix-community/ethereum.nix#op-supervisor -- --help`
- **Nix**: [packages/op-supervisor/package.nix](packages/op-supervisor/package.nix)

</details>
<details>
<summary><strong>op-validator</strong> - Tool for validating Optimism chain configurations and deployments</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/ethereum-optimism/optimism/tree/develop/op-validator
- **Usage**: `nix run github:nix-community/ethereum.nix#op-validator -- --help`
- **Nix**: [packages/op-validator/package.nix](packages/op-validator/package.nix)

</details>
<details>
<summary><strong>proxyd</strong> - RPC request router and proxy for Optimism</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/ethereum-optimism/infra/tree/main/proxyd
- **Usage**: `nix run github:nix-community/ethereum.nix#proxyd -- --help`
- **Nix**: [packages/proxyd/package.nix](packages/proxyd/package.nix)

</details>
<details>
<summary><strong>supersim</strong> - Local Multi-L2 Development Environment</summary>

- **Source**: source
- **License**: MIT
- **Homepage**: https://github.com/ethereum-optimism/supersim
- **Usage**: `nix run github:nix-community/ethereum.nix#supersim -- --help`
- **Nix**: [packages/supersim/package.nix](packages/supersim/package.nix)

</details>

### Staking

<details>
<summary><strong>eigenlayer</strong> - Utility manages core operator functionalities like local key management, operator registration and updates</summary>

- **Source**: source
- **License**: BUSL-1.1
- **Homepage**: https://www.eigenlayer.xyz/
- **Usage**: `nix run github:nix-community/ethereum.nix#eigenlayer -- --help`
- **Nix**: [packages/eigenlayer/package.nix](packages/eigenlayer/package.nix)

</details>
<details>
<summary><strong>ethstaker-deposit-cli</strong> - Secure key generation for deposits (ethstaker fork)</summary>

- **Source**: binary
- **License**: CC0-1.0
- **Homepage**: https://github.com/ethstaker/ethstaker-deposit-cli/
- **Usage**: `nix run github:nix-community/ethereum.nix#ethstaker-deposit-cli -- --help`
- **Nix**: [packages/ethstaker-deposit-cli/package.nix](packages/ethstaker-deposit-cli/package.nix)

</details>
<details>
<summary><strong>rocketpool</strong> - Rocket Pool CLI</summary>

- **Source**: source
- **License**: GPL-3.0-only
- **Homepage**: https://github.com/rocket-pool/smartnode
- **Usage**: `nix run github:nix-community/ethereum.nix#rocketpool -- --help`
- **Nix**: [packages/rocketpool/package.nix](packages/rocketpool/package.nix)

</details>
<details>
<summary><strong>rocketpoold</strong> - Rocket Pool Daemon</summary>

- **Source**: source
- **License**: GPL-3.0-only
- **Homepage**: https://github.com/rocket-pool/smartnode
- **Usage**: `nix run github:nix-community/ethereum.nix#rocketpoold -- --help`
- **Nix**: [packages/rocketpoold/package.nix](packages/rocketpoold/package.nix)

</details>
<details>
<summary><strong>staking-deposit-cli</strong> - Secure key generation for deposits</summary>

- **Source**: binary
- **License**: CC0-1.0
- **Homepage**: https://github.com/ethereum/staking-deposit-cli
- **Usage**: `nix run github:nix-community/ethereum.nix#staking-deposit-cli -- --help`
- **Nix**: [packages/staking-deposit-cli/package.nix](packages/staking-deposit-cli/package.nix)

</details>
<!-- END GENERATED PACKAGE DOCS -->

## Installation

### Using Nix Flakes (Recommended)

Add to your system configuration:

```nix
{
  inputs = {
    ethereum.url = "github:nix-community/ethereum.nix";
  };

  # In your system packages:
  environment.systemPackages = with inputs.ethereum.packages.${pkgs.stdenv.hostPlatform.system}; [
    geth
    lighthouse
    reth
    mev-boost
    # ... other tools
  ];
}
```

### Using Overlay

Alternatively, use the overlay to access packages under the `ethereum` namespace:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ethereum.url = "github:nix-community/ethereum.nix";
  };

  outputs = { nixpkgs, ethereum, ... }: {
    # NixOS configuration
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [{
        nixpkgs.overlays = [ ethereum.overlays.default ];
        environment.systemPackages = [
          pkgs.ethereum.geth
          pkgs.ethereum.lighthouse
          pkgs.ethereum.prysm
        ];
      }];
    };
  };
}
```

### Try Without Installing

```bash
# Try Geth (Execution Client)
nix run github:nix-community/ethereum.nix#geth -- --help

# Try Lighthouse (Consensus Client)
nix run github:nix-community/ethereum.nix#lighthouse -- --help

# Try Reth (Execution Client)
nix run github:nix-community/ethereum.nix#reth -- --help

# Try MEV-Boost
nix run github:nix-community/ethereum.nix#mev-boost -- --help

# etc...
```

## Development

We use [`devshell`](https://github.com/numtide/devshell) to have nice development environments. Otherwise:

```bash
nix develop
```

### Building Packages

```bash
# Build a specific package
nix build .#foundry
nix build .#geth
nix build .#nimbus
# etc...
```

### Running checks

To run all tests:

```bash
nix flake check
```

### Formatting

You can manually format the source:

```bash
nix fmt
```

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

## License

Individual tools are licensed under their respective licenses.

The Nix packaging code in this repository is licensed under MIT.
