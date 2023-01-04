_: prev: {
  # consensus clients
  lighthouse = prev.callPackage ./packages/clients/consensus/lighthouse {};
  prysm = prev.callPackage ./packages/clients/consensus/prysm {};
  teku = prev.callPackage ./packages/clients/consensus/teku {};

  # execution clients
  erigon = prev.callPackage ./packages/clients/execution/erigon {};
  inherit (prev.callPackage ./packages/clients/execution/geth {}) mkGeth geth;
  mev-geth = prev.callPackage ./packages/clients/execution/mev-geth {};
  plugeth = prev.callPackage ./packages/clients/execution/plugeth {};
  geth-sealer = prev.callPackage ./packages/clients/execution/geth-sealer {};
  nethermind = prev.callPackage ./packages/clients/execution/nethermind {};

  # signers
  web3signer = prev.callPackage ./packages/signers/web3signer {};

  # mev
  mev-boost = prev.callPackage ./packages/mev/mev-boost {};

  # utils
  ethdo = prev.callPackage ./packages/utils/ethdo {};

  # libs
  evmc = prev.callPackage ./packages/libs/evmc {};
  mcl = prev.callPackage ./packages/libs/mcl {};
  bls = prev.callPackage ./packages/libs/bls {};
  blst = prev.callPackage ./packages/libs/blst {};
}
