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
    inherit (lib) mkApp mkIf optionals elem attrByPath assertMsg flatten listToAttrs mapAttrs attrValues filterAttrs;

    callPackage = path: args: system: let
      drv = pkgs.callPackage path args;
      platforms = attrByPath ["meta" "platforms"] [] drv;
    in
      assert assertMsg (platforms != []) "meta.platforms must be present and non-empty in derivation located at: ${path}";
      # compare the provided system against the derivation's supported platforms
        mkIf (elem system platforms) drv;

    mergeForSystem = system: attrs: let
      withSystem = mapAttrs (_: v: v system) attrs;
    in
      # filter out the nulls
      filterAttrs (_: v: v != null) (
        # map entries to their content where the condition has evaluated to true
        # return null otherwise
        mapAttrs (_: v:
          if v.condition
          then v.content
          else null)
        withSystem
      );
  in {
    packages = mergeForSystem system {
      # Consensus Clients
      lighthouse = callPackage ./clients/consensus/lighthouse {};
      prysm = callPackage ./clients/consensus/prysm {inherit (self'.packages) bls blst;};
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
      dirk = callPackage ./signers/dirk {inherit (self'.packages) bls mcl;};

      # Validators
      vouch = callPackage ./validators/vouch {inherit (self'.packages) bls mcl;};

      # MEV
      mev-boost = callPackage ./mev/mev-boost {inherit (self'.packages) blst;};
      mev-rs = callPackage ./mev/mev-rs {};

      # Utils
      ethdo = callPackage ./utils/ethdo {inherit (self'.packages) bls mcl;};
      sedge = callPackage ./utils/sedge {inherit (self'.packages) bls mcl;};

      # Libs
      evmc = callPackage ./libs/evmc {};
      mcl = callPackage ./libs/mcl {};
      bls = callPackage ./libs/bls {};
      blst = callPackage ./libs/blst {};
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
