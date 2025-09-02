{
  self,
  inputs,
  lib,
  ...
}: {
  # add all our packages based on host platform
  flake.overlays.default = _final: prev: let
    inherit (prev.stdenv.hostPlatform) system;
  in
    if builtins.hasAttr system self.packages
    then self.packages.${system}
    else {};

  perSystem = {
    self',
    pkgs,
    pkgsUnstable,
    system,
    ...
  }: let
    inherit (pkgs) callPackage;
    inherit (lib) platformPkgs platformApps;
    callPackageUnstable = pkgsUnstable.callPackage;
  in {
    packages = platformPkgs system rec {
      besu = callPackage ./by-name/besu {};
      bls = callPackage ./by-name/bls {};
      blst = callPackage ./by-name/blst {};
      blutgang = callPackage ./by-name/blutgang {inherit (pkgsUnstable) rustPlatform;};
      charon = callPackageUnstable ./by-name/charon {inherit bls mcl;};
      ckzg = callPackage ./by-name/ckzg {};
      dirk = callPackage ./by-name/dirk {inherit bls mcl;};
      eigenlayer = callPackage ./by-name/eigenlayer {};
      erigon = callPackage ./by-name/erigon {};
      eth2-testnet-genesis = callPackage ./by-name/eth2-testnet-genesis {inherit bls;};
      eth2-val-tools = callPackage ./by-name/eth2-val-tools {inherit bls mcl;};
      eth-validator-watcher = callPackage ./by-name/eth-validator-watcher {};
      ethdo = callPackage ./by-name/ethdo {inherit bls mcl;};
      ethereal = callPackage ./by-name/ethereal {};
      ethstaker-deposit-cli = callPackage ./by-name/ethstaker-deposit-cli {};
      evmc = callPackage ./by-name/evmc {};
      foundry = callPackageUnstable ./by-name/foundry {};
      foundry-bin = inputs.foundry-nix.defaultPackage.${system}.overrideAttrs (_oldAttrs: {
        # TODO: Uncomment when https://github.com/shazow/foundry.nix/issues/23
        # meta.platforms = [system];
        meta.platforms = [
          "x86_64-linux"
          "aarch64-linux"
        ];
      });
      geth = callPackage ./by-name/geth {};
      heimdall = callPackage ./by-name/heimdall {};
      lighthouse = callPackage ./by-name/lighthouse {inherit foundry;};
      mcl = callPackage ./by-name/mcl {};
      mev-boost = callPackage ./by-name/mev-boost {inherit blst;};
      mev-boost-relay = callPackage ./by-name/mev-boost-relay {inherit blst;};
      nethermind = callPackage ./by-name/nethermind {};
      nimbus = callPackage ./by-name/nimbus {};
      prysm = callPackage ./by-name/prysm {inherit bls blst ckzg;};
      reth = callPackage ./by-name/reth {};
      rocketpool = callPackageUnstable ./by-name/rocketpool {};
      rocketpoold = callPackageUnstable ./by-name/rocketpoold {inherit bls blst;};
      rotki-bin = callPackage ./by-name/rotki-bin {};
      sedge = callPackage ./by-name/sedge {
        bls = callPackage ./by-name/bls {};
        mcl = callPackage ./by-name/mcl {};
      };
      slither = callPackage ./by-name/slither {};
      snarkjs = callPackage ./by-name/snarkjs {};
      ssv-dkg = callPackage ./by-name/ssv-dkg {
        bls = callPackage ./by-name/bls {};
        mcl = callPackage ./by-name/mcl {};
      };
      ssvnode = callPackage ./by-name/ssvnode {
        bls = callPackage ./by-name/bls {};
        mcl = callPackage ./by-name/mcl {};
      };
      staking-deposit-cli = callPackage ./by-name/staking-deposit-cli {};
      teku = callPackage ./by-name/teku {};
      tx-fuzz = callPackage ./by-name/tx-fuzz {};
      vouch = callPackage ./by-name/vouch {inherit bls mcl;};
      web3signer = callPackage ./by-name/web3signer {};
      zcli = callPackage ./by-name/zcli {};
    };

    apps = platformApps self'.packages {
      besu.bin = "besu";
      blutgang.bin = "blutgang";
      charon.bin = "charon";
      dirk.bin = "dirk";
      erigon.bin = "erigon";
      eth2-testnet-genesis.bin = "eth2-testnet-genesis";
      eth2-val-tools.bin = "eth2-val-tools";
      ethdo.bin = "ethdo";
      ethereal.bin = "ethereal";
      foundry = {
        anvil.bin = "anvil";
        cast.bin = "cast";
        forge.bin = "forge";
      };
      geth = {
        bin = "geth";
        geth-abidump.bin = "abidump";
        geth-abigen.bin = "abigen";
        geth-blsync.bin = "blsync";
        geth-bootnode.bin = "bootnode";
        geth-clef.bin = "clef";
        geth-devp2p.bin = "devp2p";
        geth-ethkey.bin = "ethkey";
        geth-evm.bin = "evm";
        geth-faucet.bin = "faucet";
        geth-rlpdump.bin = "rlpdump";
      };
      lighthouse.bin = "lighthouse";
      mev-boost-relay.bin = "mev-boost-relay";
      mev-boost.bin = "mev-boost";
      nethermind = {
        nethermind.bin = "Nethermind.Cli";
        nethermind-runner.bin = "Nethermind.Runner";
      };
      nimbus = {
        nimbus-beacon-node.bin = "nimbus_beacon_node";
        nimbus-validator-client.bin = "nimbus_validator_client";
      };
      prysm = {
        prysm-beacon-chain.bin = "beacon-chain";
        prysm-validator.bin = "validator";
        prysm-client-stats.bin = "client-stats";
        prysm-ctl.bin = "prysmctl";
      };
      reth.bin = "reth";
      rocketpool.bin = "rocketpool";
      rotki-bin.bin = "rotki";
      sedge.bin = "sedge";
      slither.bin = "slither";
      snarkjs.bin = "snarkjs";
      ssv-dkg.bin = "ssv-dkg";
      ssvnode.bin = "ssvnode";
      staking-deposit-cli.bin = "deposit";
      teku.bin = "teku";
      tx-fuzz.bin = "tx-fuzz";
      vouch.bin = "vouch";
      zcli.bin = "zcli";
    };
  };
}
