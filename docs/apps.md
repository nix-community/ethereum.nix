# Apps

The list of supported apps is growing every day! We plan to keep this list up to date, but, if we have missed any, please let us know!

!!! note
    Every command has a local and a remote variant. The local variant requires that the command is run from within the cloned repo. The remote variant can be run from wherever.

    - **Local**: `nix run .#my-app-name`
    - **Remote**: `nix run github:nix-community/ethereum.nix#my-app-name`

    For brevity and consistency, all the commands are listed in the local variant.

## Consenus Clients

The consensus client (also known as the Beacon Node, CL client or formerly the Eth2 client) implements the proof-of-stake consensus algorithm, which enables the network to achieve agreement based on validated data from the execution client.

| App                                                           | Supported                                  | Command                                                                                                                       |
| ------------------------------------------------------------- | ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| [Lighthouse](https://lighthouse.sigmaprime.io/)               | :material-check:{ style="color: #4DB6AC" } | `nix run .#lighthouse`                                                                                                        |
| [Lodestar](https://lodestar.chainsafe.io/)                    | :material-close:{ style="color: #EF5350" } | Not available yet.                                                                                                            |
| [Prysm](https://prysmaticlabs.com/)                           | :material-check:{ style="color: #4DB6AC" } | `nix run .#prysm-beacon-chain`<br>`nix run .#prysm-validator`<br>`nix run .#prysm-client-stats`<br>`nix run .#prysm-prysmctl` |
| [Teku](https://consensys.net/knowledge-base/ethereum-2/teku/) | :material-check:{ style="color: #4DB6AC" } | `nix run .#teku`                                                                                                              |
| [Nimbus](https://github.com/status-im/nimbus-eth2)            | :material-close:{ style="color: #EF5350" } | Not available yet.                                                                                                            |

## Execution Clients

The execution client (also known as the Execution Engine, EL client or formerly the Eth1 client) listens to new transactions broadcasted in the network, executes them in EVM, and holds the latest state and database of all current Ethereum data.

| App                                             | Supported                                  | Command                                                                                                                                                                                                                                                           |
| ----------------------------------------------- | ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Besu](https://besu.hyperledger.org/en/stable/) | :material-check:{ style="color: #4DB6AC" } | `nix run .#besu`                                                                                                                                                                                                                                                  |
| [Erigon](https://github.com/ledgerwatch/erigon) | :material-check:{ style="color: #4DB6AC" } | `nix run .#erigon`                                                                                                                                                                                                                                                |
| [Geth](https://geth.ethereum.org/)              | :material-check:{ style="color: #4DB6AC" } | `nix run .#geth`<br>`nix run .#geth-abidump`<br>`nix run .#geth-abigen`<br>`nix run .#geth-bootnode`<br>`nix run .#geth-clef`<br>`nix run .#geth-devp2p`<br>`nix run .#geth-ethky`<br>`nix run .#geth-evm`<br>`nix run .#geth-faucet`<br>`nix run .#geth-rlpdump` |
| [Nethermind](https://nethermind.io/)            | :material-check:{ style="color: #4DB6AC" } | `nix run .#nethermind-runner`<br>`nix run .#nethermind`                                                                                                                                                                                                           |

## DVT (Distributed Validator Technology)

Distributed validator technology (DVT) is an approach to validator security that spreads out key management and signing responsibilities across multiple parties, to reduce single points of failure, and increase validator resiliency.

| App                                                | Supported                                  | Command             |
| -------------------------------------------------- | ------------------------------------------ | ------------------- |
| [Charon](https://docs.obol.tech/docs/charon/intro) | :material-check:{ style="color: #4DB6AC" } | `nix run .#charon`  |
| [SSVNode](https://github.com/bloxapp/ssv)          | :material-check:{ style="color: #4DB6AC" } | `nix run .#ssvnode` |

## Editors

### Visual Studio Code (VSCode)

The following extensions are supported:

| Extension                                                                           | Supported                                  | Command        |
| ----------------------------------------------------------------------------------- | ------------------------------------------ | -------------- |
| [VSCode Solidity Auditor](https://github.com/ConsenSys/vscode-solidity-auditor)     | :material-check:{ style="color: #4DB6AC" } | Not available. |
| [Tools for Solidity](https://github.com/Ackee-Blockchain/tools-for-solidity-vscode) | :material-check:{ style="color: #4DB6AC" } | Not available. |

## MEV (Maximal Extractable Value)

Maximal extractable value (MEV) refers to the maximum value that can be extracted from block production in excess of the standard block reward and gas fees by including, excluding, and changing the order of transactions in a block.

| App                                                             | Supported                                  | Command            |
| --------------------------------------------------------------- | ------------------------------------------ | ------------------ |
| [Dreamboat](https://github.com/blocknative/dreamboat)           | :material-check:{ style="color: #4DB6AC" } | `nix run .#dreamboat`   |
| [mev-boost](https://github.com/flashbots/mev-boost)             | :material-check:{ style="color: #4DB6AC" } | `nix run .#mev-boost` |
| [mev-boost-builder](https://github.com/flashbots/builder)       | :material-check:{ style="color: #4DB6AC" } | `nix run .#mev-boost-builder` |
| [mev-boost-prysm](https://github.com/flashbots/prysm)           | :material-check:{ style="color: #4DB6AC" } | `nix run .#mev-boost-prysm` |
| [mev-boost-relay](https://github.com/flashbots/mev-boost-relay) | :material-check:{ style="color: #4DB6AC" } | `nix run .#mev-boost-relay` |
| [mev-rs](https://github.com/ralexstokes/mev-rs)                 | :material-check:{ style="color: #4DB6AC" } | `nix run .#mev` |

## Signers

| App                                                   | Supported                                  | Command            |
| ----------------------------------------------------- | ------------------------------------------ | ------------------ |
| [Dirk](https://github.com/attestantio/dirk)           | :material-check:{ style="color: #4DB6AC" } | `nix run .#dirk`   |
| [web3signer](https://github.com/ConsenSys/web3signer) | :material-check:{ style="color: #4DB6AC" } | `nix run .#erigon` |

## Utils

Utilities and applications can't be categorized into any category of the above.

| App                                                                         | Supported                                  | Command            |
| --------------------------------------------------------------------------- | ------------------------------------------ | ------------------ |
| [eth2-testnet-genesis](https://github.com/protolambda/eth2-testnet-genesis) | :material-check:{ style="color: #4DB6AC" } | `nix run .#eth2-testnet-genesis`   |
| [ethdo](https://github.com/wealdtech/ethdo)                                 | :material-check:{ style="color: #4DB6AC" } | `nix run .#ethdo` |
| [ethereal](https://github.com/wealdtech/ethereal)                           | :material-check:{ style="color: #4DB6AC" } | `nix run .#ethereal` |
| [sedge](https://github.com/NethermindEth/sedge)                             | :material-check:{ style="color: #4DB6AC" } | `nix run .#sedge` |
| [staking-deposit-cli](https://github.com/ethereum/staking-deposit-cli)      | :material-check:{ style="color: #4DB6AC" } | `nix run .#deposit` |
| [zcli](https://github.com/protolambda/zcli)                                 | :material-check:{ style="color: #4DB6AC" } | `nix run .#zcli` |

## Validators

Standalone validators clients.

| App                                            | Supported                                  | Command           |
| ---------------------------------------------- | ------------------------------------------ | ----------------- |
| [Vouch](https://github.com/attestantio/vouch/) | :material-check:{ style="color: #4DB6AC" } | `nix run .#vouch` |
