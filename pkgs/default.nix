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
    inherit (lib.extras.flakes) platformPkgs platformApps;
    callPackageUnstable = pkgsUnstable.callPackage;
    callPackage2311 = pkgs2311.callPackage;
  in {
    packages = platformPkgs system rec {
      besu = callPackageUnstable ./besu {};
      bls = callPackage ./bls {};
      blst = callPackage ./blst {};
      blutgang = callPackage ./blutgang {inherit (pkgsUnstable) rustPlatform;};
      charon = callPackage ./charon {inherit bls mcl;};
      dirk = callPackage ./dirk {inherit bls mcl;};
      dreamboat = callPackage ./dreamboat {inherit blst;};
      eigenlayer = callPackage ./eigenlayer {};
      erigon = callPackage ./erigon {};
      eth2-testnet-genesis = callPackage ./eth2-testnet-genesis {inherit bls;};
      eth2-val-tools = callPackage ./eth2-val-tools {inherit bls mcl;};
      eth-validator-watcher = callPackage2311 ./eth-validator-watcher {};
      ethdo = callPackage ./ethdo {inherit bls mcl;};
      ethereal = callPackage ./ethereal {inherit bls mcl;};
      evmc = callPackage ./evmc {};
      foundry = callPackageUnstable ./foundry {};
      foundry-bin = inputs.foundry-nix.defaultPackage.${system}.overrideAttrs (_oldAttrs: {
        # TODO: Uncomment when https://github.com/shazow/foundry.nix/issues/23
        # meta.platforms = [system];
        meta.platforms = ["x86_64-linux" "aarch64-linux"];
      });
      geth = callPackage ./geth {};
      geth-sealer = callPackage ./geth-sealer {};
      heimdall = callPackage ./heimdall {};
      lighthouse = callPackageUnstable ./lighthouse {inherit foundry;};
      mcl = callPackage ./mcl {};
      mev-boost = callPackage ./mev-boost {inherit blst;};
      mev-boost-builder = callPackage ./mev-boost-builder {inherit blst;};
      mev-boost-relay = callPackage ./mev-boost-relay {inherit blst;};
      mev-rs = callPackage ./mev-rs {};
      nethermind = callPackageUnstable ./nethermind {};
      nimbus = callPackageUnstable ./nimbus {};
      prysm = callPackage ./prysm {inherit bls blst;};
      reth = callPackageUnstable ./reth {};
      rocketpool = callPackage ./rocketpool {};
      rocketpoold = callPackage ./rocketpoold {inherit bls blst;};
      rotki-bin = callPackage2311 ./rotki-bin {};
      sedge = callPackage2311 ./sedge {
        bls = callPackage2311 ./bls {};
        mcl = callPackage2311 ./mcl {};
      };
      slither = callPackage ./slither {};
      snarkjs = callPackage ./snarkjs {};
      ssvnode = callPackage2311 ./ssvnode {
        bls = callPackage2311 ./bls {};
        mcl = callPackage2311 ./mcl {};
      };
      staking-deposit-cli = callPackage ./staking-deposit-cli {};
      teku = callPackage ./teku {};
      tx-fuzz = callPackage ./tx-fuzz {};
      vouch = callPackage ./vouch {inherit bls mcl;};
      vouch-unstable = callPackage ./vouch/unstable.nix {inherit bls mcl;};
      vscode-plugin-ackee-blockchain-solidity-tools = callPackage ./ackee-blockchain.solidity-tools {};
      vscode-plugin-consensys-vscode-solidity-visual-editor = callPackage ./consensys.vscode-solidity-auditor {};
      web3signer = callPackage ./web3signer {};
      zcli = callPackage ./zcli {};
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
      ssvnode.bin = "ssvnode";
      staking-deposit-cli.bin = "deposit";
      teku.bin = "teku";
      tx-fuzz.bin = "tx-fuzz";
      vouch.bin = "vouch";
      zcli.bin = "zcli";
    };
  };
}
