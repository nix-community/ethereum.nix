## Overview

The node keys for the various test processes are as follows:

| Filename                   | Key                                                                                                                                |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `./testing/keys/alpha.key` | `078ebf4ec2530b49773acb15c2261d149427ee6464fbbce099af762bcdc16a403501e31c4ca15198c8a1e88bd5d0a35dcd929b22387249829c04aa9214a94f44` |
| `./testing/keys/beta.key`  | `bbee5561cb95086c1dbcb2146d029286aeec6cdaec081cc88cb0a676de390cd121512d1c018c0bfe3716bd92dd1f0ff91721f61ff460e9370a0df2cb77fd8e1a` |
| `./testing/keys/gamma.key` | `2916650bd333498b83abd94ccdae54392d3cc81db3cadfd09f93ffe9eb7d072bd0a567e08341741050b54c11a98a9cde1132e490e199f14099160828ecfe70ab` |

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
