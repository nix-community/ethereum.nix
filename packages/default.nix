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
    inherit (lib.attrs) filterAttrs;
    inherit (lib.flake) mkAppForSystem mergeForSystem callPackage;
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

    apps = mergeForSystem system {
      # consensus clients / prysm
      prysm-beacon-chain = mkAppForSystem {
        inherit self';
        name = _: "beacon-chain";
        drvName = "prysm";
      };
      prysm-validator = mkAppForSystem {
        inherit self';
        name = _: "validator";
        drvName = "prysm";
      };
      prysm-client-stats = mkAppForSystem {
        inherit self';
        name = _: "client-stats";
        drvName = "prysm";
      };
      prysm-ctl = mkAppForSystem {
        inherit self';
        name = _: "prysmctl";
        drvName = "prysm";
      };

      # consensus / teku
      teku = mkAppForSystem {
        inherit self';
        drvName = "teku";
      };

      # consensus / lighthouse
      lighthouse = mkAppForSystem {
        inherit self';
        drvName = "lighthouse";
      };

      # execution clients
      besu = mkAppForSystem {
        inherit self';
        drvName = "besu";
      };
      erigon = mkAppForSystem {
        inherit self';
        drvName = "erigon";
      };

      geth = mkAppForSystem {
        inherit self';
        drvName = "geth";
      };
      geth-abidump = mkAppForSystem {
        inherit self';
        name = _: "abidump";
        drvName = "geth";
      };
      geth-abigen = mkAppForSystem {
        inherit self';
        name = _: "abigen";
        drvName = "geth";
      };
      geth-bootnode = mkAppForSystem {
        inherit self';
        name = _: "bootnode";
        drvName = "geth";
      };
      geth-clef = mkAppForSystem {
        inherit self';
        name = _: "clef";
        drvName = "geth";
      };
      geth-devp2p = mkAppForSystem {
        inherit self';
        name = _: "devp2p";
        drvName = "geth";
      };
      geth-ethkey = mkAppForSystem {
        inherit self';
        name = _: "ethkey";
        drvName = "geth";
      };
      geth-evm = mkAppForSystem {
        inherit self';
        name = _: "evm";
        drvName = "geth";
      };
      geth-faucet = mkAppForSystem {
        inherit self';
        name = _: "faucet";
        drvName = "geth";
      };
      geth-rlpdump = mkAppForSystem {
        inherit self';
        name = _: "rlpdump";
        drvName = "geth";
      };

      geth-sealer = mkAppForSystem {
        inherit self';
        name = _: "geth";
        drvName = "geth-sealer";
      };
      mev-geth = mkAppForSystem {
        inherit self';
        name = _: "geth";
        drvName = "mev-geth";
      };
      nethermind = mkAppForSystem {
        inherit self';
        name = _: "Nethermind.Cli";
        drvName = "nethermind";
      };
      nethermind-runner = mkAppForSystem {
        inherit self';
        name = _: "Nethermind.Runner";
        drvName = "nethermind";
      };
      plugeth = mkAppForSystem {
        inherit self';
        name = _: "geth";
        drvName = "plugeth";
      };

      # mev
      mev-boost = mkAppForSystem {
        inherit self';
        drvName = "mev-boost";
      };
      mev-rs = mkAppForSystem {
        inherit self';
        name = _: "mev";
        drvName = "mev-rs";
      };

      # Signers
      dirk = mkAppForSystem {
        inherit self';
        drvName = "dirk";
      };

      # Validators
      vouch = mkAppForSystem {
        inherit self';
        drvName = "vouch";
      };

      # utils
      ethdo = mkAppForSystem {
        inherit self';
        drvName = "ethdo";
      };
      sedge = mkAppForSystem {
        inherit self';
        drvName = "sedge";
      };
    };

    overlayAttrs = self'.packages;
  };
}
