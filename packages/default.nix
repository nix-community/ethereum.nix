{
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkApp;
in {
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem = {
    self',
    config,
    pkgs,
    ...
  }: {
    packages = rec {
      # Consensus Clients
      lighthouse = pkgs.callPackage ./clients/consensus/lighthouse {};
      prysm = pkgs.callPackage ./clients/consensus/prysm {inherit bls blst;};
      teku = pkgs.callPackage ./clients/consensus/teku {};

      # Execution Clients
      erigon = pkgs.callPackage ./clients/execution/erigon {};
      geth = pkgs.callPackage ./clients/execution/geth {};
      mev-geth = pkgs.callPackage ./clients/execution/mev-geth {};
      plugeth = pkgs.callPackage ./clients/execution/plugeth {};
      geth-sealer = pkgs.callPackage ./clients/execution/geth-sealer {};
      nethermind = pkgs.callPackage ./clients/execution/nethermind {};

      # Signers
      web3signer = pkgs.callPackage ./signers/web3signer {};
      dirk = pkgs.callPackage ./signers/dirk {inherit bls mcl;};

      # Validators
      vouch = pkgs.callPackage ./validators/vouch {inherit bls mcl;};

      # MEV
      mev-boost = pkgs.callPackage ./mev/mev-boost {inherit blst;};
      mev-rs = pkgs.callPackage ./mev/mev-rs {};

      # Utils
      ethdo = pkgs.callPackage ./utils/ethdo {inherit bls mcl;};
      sedge = pkgs.callPackage ./utils/sedge {inherit bls mcl;};

      # Libs
      evmc = pkgs.callPackage ./libs/evmc {};
      mcl = pkgs.callPackage ./libs/mcl {};
      bls = pkgs.callPackage ./libs/bls {};
      blst = pkgs.callPackage ./libs/blst {};
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
      # TODO: Backport Besu to ethereum.nix
      # besu = mkApp {
      #   drv = besu;
      # };
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
        mev-rs
        mev-geth
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
