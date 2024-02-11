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
    self.packages.${system};

  perSystem = {
    self',
    pkgs,
    pkgsUnstable,
    system,
    ...
  }: let
    inherit (pkgs) callPackage;
    inherit (lib.extras.flakes) platformPkgs platformApps;
    poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;};
    callPackageUnstable = pkgsUnstable.callPackage;
  in {
    packages = platformPkgs system rec {
      # Consensus Clients
      lighthouse = callPackage ./lighthouse {inherit foundry;};
      prysm = callPackage ./prysm {inherit bls blst;};
      teku = callPackage ./teku {};
      nimbus = callPackageUnstable ./nimbus {};

      # Execution Clients
      erigon = callPackage ./erigon {};
      besu = callPackage ./besu {};
      geth = callPackage ./geth {};
      geth-sealer = callPackage ./geth-sealer {};
      nethermind = callPackage ./nethermind {};
      reth = callPackageUnstable ./reth {};

      # Signers
      web3signer = callPackage ./web3signer {};
      dirk = callPackage ./dirk {inherit bls mcl;};

      # Validators
      vouch = callPackage ./vouch {inherit bls mcl;};

      # MEV
      dreamboat = callPackage ./dreamboat {inherit blst;};
      mev-boost = callPackage ./mev-boost {inherit blst;};
      mev-boost-builder = callPackage ./mev-boost-builder {inherit blst;};
      mev-boost-prysm = callPackage ./mev-boost-prysm {inherit bls blst;};
      mev-boost-relay = callPackage ./mev-boost-relay {inherit blst;};

      mev-rs = callPackage ./mev-rs {};

      # DVT
      charon = callPackage ./charon {inherit bls mcl;};
      ssvnode = callPackage ./ssvnode {inherit bls mcl;};

      # Utils
      eigenlayer = callPackage ./eigenlayer {};
      eth2-testnet-genesis = callPackage ./eth2-testnet-genesis {inherit bls;};
      eth2-val-tools = callPackage ./eth2-val-tools {inherit bls mcl;};
      ethdo = callPackage ./ethdo {inherit bls mcl;};
      ethereal = callPackage ./ethereal {inherit bls mcl;};
      heimdall = callPackage ./heimdall {};
      rocketpool = callPackage ./rocketpool {};
      sedge = callPackage ./sedge {inherit bls mcl;};
      staking-deposit-cli = callPackage ./staking-deposit-cli {};
      tx-fuzz = callPackage ./tx-fuzz {};
      zcli = callPackage ./zcli {};

      # Dev
      foundry = callPackageUnstable ./foundry {};
      foundry-bin = inputs.foundry-nix.defaultPackage.${system}.overrideAttrs (_oldAttrs: {
        # TODO: Uncomment when https://github.com/shazow/foundry.nix/issues/23
        # meta.platforms = [system];
        meta.platforms = ["x86_64-linux" "aarch64-linux"];
      });

      # Editors
      vscode-plugin-ackee-blockchain-solidity-tools = callPackage ./ackee-blockchain.solidity-tools {};
      vscode-plugin-consensys-vscode-solidity-visual-editor = callPackage ./consensys.vscode-solidity-auditor {};

      # Solidity
      slither = callPackage ./slither {};
      wake = callPackage ./wake {
        inherit poetry2nix;
      };

      # Libs
      evmc = callPackage ./evmc {};
      mcl = callPackage ./mcl {};
      bls = callPackage ./bls {};
      blst = callPackage ./blst {};
    };

    apps = platformApps self'.packages {
      # consensus clients / prysm
      prysm = {
        prysm-beacon-chain.bin = "beacon-chain";
        prysm-validator.bin = "validator";
        prysm-client-stats.bin = "client-stats";
        prysm-ctl.bin = "prysmctl";
      };

      # consensus / teku
      teku.bin = "teku";

      # consensus / lighthouse
      lighthouse.bin = "lighthouse";

      # consensus / nimbus
      nimbus = {
        nimbus-beacon-node.bin = "nimbus_beacon_node";
        nimbus-validator-client.bin = "nimbus_validator_client";
      };

      # execution clients
      besu.bin = "besu";
      erigon.bin = "erigon";
      reth.bin = "reth";

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

      nethermind = {
        nethermind.bin = "Nethermind.Cli";
        nethermind-runner.bin = "Nethermind.Runner";
      };

      # dvt
      charon.bin = "charon";
      ssvnode.bin = "ssvnode";

      # mev
      dreamboat.bin = "dreamboat";
      mev-boost-builder.bin = "geth";
      mev-boost-prysm.bin = "beacon-chain";
      mev-boost-relay.bin = "mev-boost-relay";
      mev-boost.bin = "mev-boost";

      mev-rs.bin = "mev";

      # Signers
      dirk.bin = "dirk";

      # Validators
      vouch.bin = "vouch";

      # Dev
      foundry = {
        anvil.bin = "anvil";
        cast.bin = "cast";
        forge.bin = "forge";
      };

      # Solidity
      slither.bin = "slither";
      wake.bin = "wake";

      # utils
      eth2-testnet-genesis.bin = "eth2-testnet-genesis";
      eth2-val-tools.bin = "eth2-val-tools";
      ethdo.bin = "ethdo";
      ethereal.bin = "ethereal";
      rocketpool.bin = "rocketpool";
      sedge.bin = "sedge";
      staking-deposit-cli.bin = "deposit";
      tx-fuzz.bin = "tx-fuzz";
      zcli.bin = "zcli";
    };
  };
}
