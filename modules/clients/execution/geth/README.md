## Overview

The node keys for the various test processes are as follows:

| Filename | Key |
| `./testing/boot.key` | `1ad79035e0f92b5f98a46f87d5842c02fc09d35cf3794352a08919977e40a46f0c071e3e43cf1c9b8a50c11290f78168cb00f2d46d740714d4eb319a664f3927` |
| `./testing/geth-1/geth/nodekey` | `4baf0b7caf437c11562645b3f2bbb93b815fb5330dd5c4336a9f27d17d2292607f84bef2d62713039b7eb4db6499c07dd368f70e19e7e2565e8d256f2383031b` |
| `./testing/geth-2/geth/nodekey` | `dd27978f5936b1e233e4d5fed11fe3176b81a620a30b04a76e1866b469fbe0f47e241a0d76e1e486e346ba4d98ef17174556710e7cada61c00c98b93d5c1e651` |
| `./testing/geth-3/geth/nodekey` | `9324a762f297a061ae7e076d03d6013b2024fac716deb2465db4d6f4c6f4456b32fa76cd437fe8912fac6d5eb4324a6081735b08e91965fa1ec23fb05afe62be` |

An enode address can be constructed as follows by combining the node key with the instance ip address and port:

`enode://<key>@<ip>:<port>`

## Generating Node Keys

```shell
nix run .#geth-bootnode -- -genkey ./node.key
```

## Retrieving Node Keys

```shell
nix run .#geth-bootnode -- -writeaddress -nodekey ./node.key
```
