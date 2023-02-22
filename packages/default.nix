{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem = {
    self',
    config,
    pkgs,
    system,
    ...
  }: let
    inherit (lib.flake) mkApp mergeForSystem callPackage;
  in {
    packages = mergeForSystem system {
      # Consensus Clients
      lighthouse = callPackage pkgs ./clients/consensus/lighthouse {};
      prysm = callPackage pkgs ./clients/consensus/prysm {inherit (self'.packages) bls blst;};
      teku = callPackage pkgs ./clients/consensus/teku {};

      # Execution Clients
      erigon = callPackage pkgs ./clients/execution/erigon {};
      besu = callPackage pkgs ./clients/execution/besu {};
      geth = callPackage pkgs ./clients/execution/geth {};
      mev-geth = callPackage pkgs ./clients/execution/mev-geth {};
      plugeth = callPackage pkgs ./clients/execution/plugeth {};
      geth-sealer = callPackage pkgs ./clients/execution/geth-sealer {};
      nethermind = callPackage pkgs ./clients/execution/nethermind {};

      # Signers
      web3signer = callPackage pkgs ./signers/web3signer {};
      dirk = callPackage pkgs ./signers/dirk {inherit (self'.packages) bls mcl;};

      # Validators
      vouch = callPackage pkgs ./validators/vouch {inherit (self'.packages) bls mcl;};

      # MEV
      mev-boost = callPackage pkgs ./mev/mev-boost {inherit (self'.packages) blst;};
      mev-rs = callPackage pkgs ./mev/mev-rs {};

      # Utils
      ethdo = callPackage pkgs ./utils/ethdo {inherit (self'.packages) bls mcl;};
      sedge = callPackage pkgs ./utils/sedge {inherit (self'.packages) bls mcl;};

      # Libs
      evmc = callPackage pkgs ./libs/evmc {};
      mcl = callPackage pkgs ./libs/mcl {};
      bls = callPackage pkgs ./libs/bls {};
      blst = callPackage pkgs ./libs/blst {};
    };

    apps = with self'.packages; {
      # consensus clients / prysm
      prysm-beacon-chain = mkApp {
        name = "beacon-chain";
        drv = prysm;
      };
      prysm-validator = mkApp {
        name = "validator";
        drv = prysm;
      };
      prysm-client-stats = mkApp {
        name = "client-stats";
        drv = prysm;
      };
      prysm-ctl = mkApp {
        name = "prysmctl";
        drv = prysm;
      };

      # consensus / teku
      teku = mkApp {
        drv = teku;
      };

      # consensus / lighthouse
      lighthouse = mkApp {
        drv = lighthouse;
      };

      # execution clients
      besu = mkApp {
        drv = besu;
      };
      erigon = mkApp {
        drv = erigon;
      };

      geth = mkApp {
        drv = geth;
      };
      geth-abidump = mkApp {
        name = "abidump";
        drv = geth;
      };
      geth-abigen = mkApp {
        name = "abigen";
        drv = geth;
      };
      geth-bootnode = mkApp {
        name = "bootnode";
        drv = geth;
      };
      geth-clef = mkApp {
        name = "clef";
        drv = geth;
      };
      geth-devp2p = mkApp {
        name = "devp2p";
        drv = geth;
      };
      geth-ethkey = mkApp {
        name = "ethkey";
        drv = geth;
      };
      geth-evm = mkApp {
        name = "evm";
        drv = geth;
      };
      geth-faucet = mkApp {
        name = "faucet";
        drv = geth;
      };
      geth-rlpdump = mkApp {
        name = "rlpdump";
        drv = geth;
      };

      geth-sealer = mkApp {
        name = "geth";
        drv = geth-sealer;
      };
      mev-geth = mkApp {
        name = "geth";
        drv = mev-geth;
      };
      nethermind = mkApp {
        name = "Nethermind.Cli";
        drv = nethermind;
      };
      nethermind-runner = mkApp {
        name = "Nethermind.Runner";
        drv = nethermind;
      };
      plugeth = mkApp {
        name = "geth";
        drv = plugeth;
      };

      # mev
      mev-boost = mkApp {
        drv = mev-boost;
      };
      mev-rs = mkApp {
        name = "mev";
        drv = mev-rs;
      };

      # Signers
      dirk = mkApp {
        drv = dirk;
      };

      # Validators
      vouch = mkApp {
        drv = vouch;
      };

      # utils
      ethdo = mkApp {
        drv = ethdo;
      };
      sedge = mkApp {
        drv = sedge;
      };
    };

    overlayAttrs = {
      inherit
        (config.packages)
        besu
        bls
        blst
        dirk
        erigon
        ethdo
        evmc
        geth
        geth-sealer
        lighthouse
        mcl
        mev-boost
        mev-geth
        mev-rs
        nethermind
        plugeth
        prysm
        sedge
        teku
        vouch
        web3signer
        ;
    };
  };
}
