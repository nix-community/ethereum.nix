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
    pkgs2311,
    system,
    ...
  }: let
    inherit (pkgs) callPackage;
    inherit (lib) platformPkgs platformApps;
    callPackageUnstable = pkgsUnstable.callPackage;
    callPackage2311 = pkgs2311.callPackage;
  in {
    packages = platformPkgs system rec {
      besu = callPackageUnstable ./by-name/be/besu {};
      bls = callPackage ./by-name/bl/bls {};
      blst = callPackage ./by-name/bl/blst {};
      blutgang = callPackage ./by-name/bl/blutgang {inherit (pkgsUnstable) rustPlatform;};
      charon = callPackage ./by-name/ch/charon {inherit bls mcl;};
      dirk = callPackage ./by-name/di/dirk {inherit bls mcl;};
      dreamboat = callPackage ./by-name/dr/dreamboat {inherit blst;};
      eigenlayer = callPackage ./by-name/ei/eigenlayer {};
      erigon = callPackage ./by-name/er/erigon {};
      eth2-testnet-genesis = callPackage ./by-name/et/eth2-testnet-genesis {inherit bls;};
      eth2-val-tools = callPackage ./by-name/et/eth2-val-tools {inherit bls mcl;};
      eth-validator-watcher = callPackage2311 ./by-name/et/eth-validator-watcher {};
      ethdo = callPackage ./by-name/et/ethdo {inherit bls mcl;};
      ethereal = callPackage ./by-name/et/ethereal {};
      evmc = callPackage ./by-name/ev/evmc {};
      foundry = callPackageUnstable ./by-name/fo/foundry {};
      foundry-bin = inputs.foundry-nix.defaultPackage.${system}.overrideAttrs (_oldAttrs: {
        # TODO: Uncomment when https://github.com/shazow/foundry.nix/issues/23
        # meta.platforms = [system];
        meta.platforms = ["x86_64-linux" "aarch64-linux"];
      });
      geth = callPackageUnstable ./by-name/ge/geth {};
      geth-sealer = callPackage ./by-name/ge/geth-sealer {};
      heimdall = callPackage ./by-name/he/heimdall {};
      lighthouse = callPackageUnstable ./by-name/li/lighthouse {inherit foundry;};
      mcl = callPackage ./by-name/mc/mcl {};
      mev-boost = callPackageUnstable ./by-name/me/mev-boost {inherit blst;};
      mev-boost-builder = callPackage ./by-name/me/mev-boost-builder {inherit blst;};
      mev-boost-relay = callPackage ./by-name/me/mev-boost-relay {inherit blst;};
      mev-rs = callPackage ./by-name/me/mev-rs {};
      nethermind = callPackageUnstable ./by-name/ne/nethermind {};
      nimbus = callPackageUnstable ./by-name/ni/nimbus {};
      prysm = callPackageUnstable ./by-name/pr/prysm {inherit bls blst;};
      reth = callPackageUnstable ./by-name/re/reth {};
      rocketpool = callPackage ./by-name/ro/rocketpool {};
      rocketpoold = callPackage ./by-name/ro/rocketpoold {inherit bls blst;};
      rotki-bin = callPackageUnstable ./by-name/ro/rotki-bin {};
      sedge = callPackage2311 ./by-name/se/sedge {
        bls = callPackage2311 ./by-name/bl/bls {};
        mcl = callPackage2311 ./by-name/mc/mcl {};
      };
      slither = callPackage ./by-name/sl/slither {};
      snarkjs = callPackage ./by-name/sn/snarkjs {};
      ssv-dkg = callPackage2311 ./by-name/ss/ssv-dkg {
        bls = callPackage2311 ./by-name/bl/bls {};
        mcl = callPackage2311 ./by-name/mc/mcl {};
      };
      ssvnode = callPackage ./by-name/ss/ssvnode {
        bls = callPackage2311 ./by-name/bl/bls {};
        mcl = callPackage2311 ./by-name/mc/mcl {};
      };
      staking-deposit-cli = callPackage ./by-name/st/staking-deposit-cli {};
      teku = callPackage ./by-name/te/teku {};
      tx-fuzz = callPackage ./by-name/tx/tx-fuzz {};
      vouch = callPackage ./by-name/vo/vouch {inherit bls mcl;};
      vouch-unstable = callPackage ./by-name/vo/vouch/unstable.nix {inherit bls mcl;};
      vscode-plugin-ackee-blockchain-solidity-tools = callPackage ./by-name/ac/ackee-blockchain.solidity-tools {};
      vscode-plugin-consensys-vscode-solidity-visual-editor = callPackage ./by-name/co/consensys.vscode-solidity-auditor {};
      web3signer = callPackage ./by-name/we/web3signer {};
      zcli = callPackage ./by-name/zc/zcli {};
    };

    apps = platformApps self'.packages {
      besu.bin = "besu";
      blutgang.bin = "blutgang";
      charon.bin = "charon";
      dirk.bin = "dirk";
      dreamboat.bin = "dreamboat";
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
      geth-sealer.bin = "geth";
      lighthouse.bin = "lighthouse";
      mev-boost-builder.bin = "geth";
      mev-boost-relay.bin = "mev-boost-relay";
      mev-boost.bin = "mev-boost";
      mev-rs.bin = "mev";
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
