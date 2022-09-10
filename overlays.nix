_: prev: {
  # consensus clients
  lighthouse = prev.callPackage ./packages/clients/consensus/lighthouse {};
  prysm = prev.callPackage ./packages/clients/consensus/prysm {};
  teku = prev.callPackage ./packages/clients/consensus/teku {};

  # execution clients
  erigon = prev.callPackage ./packages/clients/execution/erigon {};
  inherit
    (prev.callPackage ./packages/clients/execution/geth {})
    buildGeth
    geth
    mev-boost
    mev-geth
    plugeth
    ;

  # utils
  ethdo = prev.callPackage ./packages/utils/ethdo {};

  # libs
  mcl = prev.callPackage ./packages/libs/mcl {};
  bls = prev.callPackage ./packages/libs/bls {};
  blst = prev.callPackage ./packages/libs/blst {};
}
