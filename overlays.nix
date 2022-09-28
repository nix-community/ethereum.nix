_: prev: {
  # consensus clients
  lighthouse = prev.callPackage ./packages/clients/consensus/lighthouse {};
  prysm = prev.callPackage ./packages/clients/consensus/prysm {};
  teku = prev.callPackage ./packages/clients/consensus/teku {};

  # execution clients
  erigon = prev.callPackage ./packages/clients/execution/erigon {};
  inherit (prev.callPackage ./packages/clients/execution/geth {}) mkGeth geth;
  mev-boost = prev.callPackage ./packages/clients/execution/mev-boost {};
  mev-geth = prev.callPackage ./packages/clients/execution/mev-geth {};
  inherit (prev.callPackage ./packages/clients/execution/plugeth {}) plugeth mkPlugeth;
  plugeth-plugins = prev.callPackage ./packages/clients/execution/plugeth/plugins.nix {};

  # utils
  ethdo = prev.callPackage ./packages/utils/ethdo {};

  # libs
  evmc = prev.callPackage ./packages/libs/evmc {};
  mcl = prev.callPackage ./packages/libs/mcl {};
  bls = prev.callPackage ./packages/libs/bls {};
  blst = prev.callPackage ./packages/libs/blst {};
}
