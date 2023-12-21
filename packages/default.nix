{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    self',
    pkgs,
    pkgsUnstable,
    system,
    ...
  }: let
    inherit (pkgs) callPackage;
    inherit (lib.extras.flakes) platformPkgs platformApps;
    callPackageUnstable = pkgsUnstable.callPackage;
  in {
    packages = platformPkgs system rec {
      # Consensus Clients
      lighthouse = callPackage ./clients/consensus/lighthouse {inherit foundry;};
      prysm = callPackage ./clients/consensus/prysm {inherit bls blst;};
      teku = callPackage ./clients/consensus/teku {};
      nimbus = callPackageUnstable ./clients/consensus/nimbus {};

      # Execution Clients
      erigon = callPackage ./clients/execution/erigon {};
      besu = callPackage ./clients/execution/besu {};
      geth = callPackage ./clients/execution/geth {};
      geth-sealer = callPackage ./clients/execution/geth-sealer {};
      nethermind = callPackage ./clients/execution/nethermind {};

      # Signers
      web3signer = callPackage ./signers/web3signer {};
      dirk = callPackage ./signers/dirk {inherit bls mcl;};

      # Validators
      vouch = callPackage ./validators/vouch {inherit bls mcl;};

      # MEV
      dreamboat = callPackage ./mev/dreamboat {inherit blst;};
      mev-boost = callPackage ./mev/mev-boost {inherit blst;};
      mev-boost-builder = callPackage ./mev/mev-boost-builder {inherit blst;};
      mev-boost-prysm = callPackage ./mev/mev-boost-prysm {inherit bls blst;};
      mev-boost-relay = callPackage ./mev/mev-boost-relay {inherit blst;};

      mev-rs = callPackage ./mev/mev-rs {};

      # DVT
      charon = callPackage ./dvt/charon {inherit bls mcl;};
      ssvnode = callPackage ./dvt/ssvnode {inherit bls mcl;};

      # Utils
      eigenlayer = callPackageUnstable ./utils/eigenlayer {};
      eth2-testnet-genesis = callPackage ./utils/eth2-testnet-genesis {inherit bls;};
      eth2-val-tools = callPackage ./utils/eth2-val-tools {inherit bls mcl;};
      ethdo = callPackage ./utils/ethdo {inherit bls mcl;};
      ethereal = callPackage ./utils/ethereal {inherit bls mcl;};
      sedge = callPackage ./utils/sedge {inherit bls mcl;};
      staking-deposit-cli = callPackage ./utils/staking-deposit-cli {};
      tx-fuzz = callPackage ./utils/tx-fuzz {};
      zcli = callPackage ./utils/zcli {};

      # Dev
      foundry = inputs.foundry-nix.defaultPackage.${system}.overrideAttrs (_oldAttrs: {
        meta.platforms = [system];
      });

      # Editors
      vscode-plugin-ackee-blockchain-solidity-tools = callPackage ./editors/vscode/extensions/ackee-blockchain.solidity-tools {};
      vscode-plugin-consensys-vscode-solidity-visual-editor = callPackage ./editors/vscode/extensions/consensys.vscode-solidity-auditor {};

      # Solidity
      slither = callPackageUnstable ./solidity/analyzers/slither {};
      wake = callPackageUnstable ./solidity/frameworks/wake {};

      # Libs
      evmc = callPackage ./libs/evmc {};
      mcl = callPackage ./libs/mcl {};
      bls = callPackage ./libs/bls {};
      blst = callPackage ./libs/blst {};
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
      nimbus.bin = "nimbus_beacon_node";

      # execution clients
      besu.bin = "besu";
      erigon.bin = "erigon";

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
      wake.bin = "woke";

      # utils
      eth2-testnet-genesis.bin = "eth2-testnet-genesis";
      eth2-val-tools.bin = "eth2-val-tools";
      ethdo.bin = "ethdo";
      ethereal.bin = "ethereal";
      sedge.bin = "sedge";
      staking-deposit-cli.bin = "deposit";
      tx-fuzz.bin = "tx-fuzz";
      zcli.bin = "zcli";
    };

    overlayAttrs = self'.packages;
  };
}
