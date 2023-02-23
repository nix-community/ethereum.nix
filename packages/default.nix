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
    inherit (lib.flake) platformPkgs mkAppForSystem mergeForSystem;
    inherit (pkgs) callPackage;
  in {
    packages = platformPkgs system rec {
      # Consensus Clients
      lighthouse = callPackage ./clients/consensus/lighthouse {};
      prysm = callPackage ./clients/consensus/prysm {inherit bls blst;};
      teku = callPackage ./clients/consensus/teku {};

      # Execution Clients
      erigon = callPackage ./clients/execution/erigon {};
      besu = callPackage ./clients/execution/besu {};
      geth = callPackage ./clients/execution/geth {};
      mev-geth = callPackage ./clients/execution/mev-geth {};
      plugeth = callPackage ./clients/execution/plugeth {};
      geth-sealer = callPackage ./clients/execution/geth-sealer {};
      nethermind = callPackage ./clients/execution/nethermind {};

      # Signers
      web3signer = callPackage ./signers/web3signer {};
      dirk = callPackage ./signers/dirk {inherit bls mcl;};

      # Validators
      vouch = callPackage ./validators/vouch {inherit bls mcl;};

      # MEV
      mev-boost = callPackage ./mev/mev-boost {inherit blst;};
      mev-rs = callPackage ./mev/mev-rs {};

      # Utils
      ethdo = callPackage ./utils/ethdo {inherit bls mcl;};
      sedge = callPackage ./utils/sedge {inherit bls mcl;};

      # Libs
      evmc = callPackage ./libs/evmc {};
      mcl = callPackage ./libs/mcl {};
      bls = callPackage ./libs/bls {};
      blst = callPackage ./libs/blst {};
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
