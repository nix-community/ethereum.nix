# Apps

The list of supported apps is growing every day! We plan to keep this list up to date, but, if we have missed any, please let us know!

!!! note
    Every command has a local and a remote variant. The local variant requires that the command is run from within the cloned repo. The remote variant can be run from wherever.

    - **Local**: `nix run .#my-app-name`
    - **Remote**: `nix run github:nix-community/ethereum.nix#my-app-name`

    For brevity and consistency, all the commands are listed in the local variant.

## Ethereum Clients

### Consenus Clients

The consensus client (also known as the Beacon Node, CL client or formerly the Eth2 client) implements the proof-of-stake consensus algorithm, which enables the network to achieve agreement based on validated data from the execution client.

::spantable::

| App                                                           | Command                        |
| ------------------------------------------------------------- | ------------------------------ |
| [Lighthouse](https://lighthouse.sigmaprime.io/)               | `nix run .#lighthouse`         |
| [Lodestar](https://lodestar.chainsafe.io/)                    | Not supported yet.             |
| [Prysm](https://prysmaticlabs.com/) @span                     | `nix run .#prysm-beacon-chain` |
|                                                               | `nix run .#prysm-validator`    |
|                                                               | `nix run .#prysm-validator`    |
|                                                               | `nix run .#prysm-client-stats` |
|                                                               | `nix run .#prysm-prysmctl`     |
| [Teku](https://consensys.net/knowledge-base/ethereum-2/teku/) | `nix run .#teku`               |
| [Nimbus](https://github.com/status-im/nimbus-eth2)            | `nix run .#teku`               |

::end-spantable::

### Execution Clients

The execution client (also known as the Execution Engine, EL client or formerly the Eth1 client) listens to new transactions broadcasted in the network, executes them in EVM, and holds the latest state and database of all current Ethereum data.

::spantable::

| App                                             | Command                       |
| ----------------------------------------------- | ----------------------------- |
| [Besu](https://besu.hyperledger.org/en/stable/) | `nix run .#besu`              |
| [Erigon](https://github.com/ledgerwatch/erigon) | `nix run .#erigon`            |
| [Geth](https://geth.ethereum.org/) @span        | `nix run .#geth`              |
|                                                 | `nix run .#geth-abidump`      |
|                                                 | `nix run .#geth-abigen`       |
|                                                 | `nix run .#geth-bootnode`     |
|                                                 | `nix run .#geth-clef`         |
|                                                 | `nix run .#geth-devp2p`       |
|                                                 | `nix run .#geth-ethky`        |
|                                                 | `nix run .#geth-evm`          |
|                                                 | `nix run .#geth-faucet`       |
|                                                 | `nix run .#geth-rlpdump`      |
| [Nethermind](https://nethermind.io/) @span      | `nix run .#nethermind-runner` |
|                                                 | `nix run .#nethermind`        |

::end-spantable::

## DVT (Distributed Validator Technology)

Distributed validator technology (DVT) is an approach to validator security that spreads out key management and signing responsibilities across multiple parties, to reduce single points of failure, and increase validator resiliency.

| App                                                | Command             |
| -------------------------------------------------- | ------------------- |
| [Charon](https://docs.obol.tech/docs/charon/intro) | `nix run .#charon`  |
| [SSVNode](https://github.com/bloxapp/ssv)          | `nix run .#ssvnode` |

## Editors

### Visual Studio Code (VSCode)

The following extensions are supported:

| Extension                                                                           | Command        |
| ----------------------------------------------------------------------------------- | -------------- |
| [VSCode Solidity Auditor](https://github.com/ConsenSys/vscode-solidity-auditor)     | Not available. |
| [Tools for Solidity](https://github.com/Ackee-Blockchain/tools-for-solidity-vscode) | Not available. |

## MEV (Maximal Extractable Value)

Maximal extractable value (MEV) refers to the maximum value that can be extracted from block production in excess of the standard block reward and gas fees by including, excluding, and changing the order of transactions in a block.

| App                                                             | Command                       |
| --------------------------------------------------------------- | ----------------------------- |
| [Dreamboat](https://github.com/blocknative/dreamboat)           | `nix run .#dreamboat`         |
| [mev-boost](https://github.com/flashbots/mev-boost)             | `nix run .#mev-boost`         |
| [mev-boost-builder](https://github.com/flashbots/builder)       | `nix run .#mev-boost-builder` |
| [mev-boost-prysm](https://github.com/flashbots/prysm)           | `nix run .#mev-boost-prysm`   |
| [mev-boost-relay](https://github.com/flashbots/mev-boost-relay) | `nix run .#mev-boost-relay`   |
| [mev-rs](https://github.com/ralexstokes/mev-rs)                 | `nix run .#mev`               |

## Signers

| App                                                   | Command            |
| ----------------------------------------------------- | ------------------ |
| [Dirk](https://github.com/attestantio/dirk)           | `nix run .#dirk`   |
| [web3signer](https://github.com/ConsenSys/web3signer) | `nix run .#erigon` |

## Utilities

Utilities and applications that can't be categorized into any category of the above.

| App                                                                         | Command                          |
| --------------------------------------------------------------------------- | -------------------------------- |
| [eth2-testnet-genesis](https://github.com/protolambda/eth2-testnet-genesis) | `nix run .#eth2-testnet-genesis` |
| [ethdo](https://github.com/wealdtech/ethdo)                                 | `nix run .#ethdo`                |
| [ethereal](https://github.com/wealdtech/ethereal)                           | `nix run .#ethereal`             |
| [sedge](https://github.com/NethermindEth/sedge)                             | `nix run .#sedge`                |
| [staking-deposit-cli](https://github.com/ethereum/staking-deposit-cli)      | `nix run .#deposit`              |
| [zcli](https://github.com/protolambda/zcli)                                 | `nix run .#zcli`                 |

## Validators

Standalone validators clients.

| App                                            | Command           |
| ---------------------------------------------- | ----------------- |
| [Vouch](https://github.com/attestantio/vouch/) | `nix run .#vouch` |
