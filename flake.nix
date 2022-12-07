{
  description = "A reproducible Nix package set for Ethereum clients and utilities";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # packages
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;

    # libraries
    fu.url = github:numtide/flake-utils;
    devshell = {
      url = github:numtide/devshell;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "fu";
    };
  };

  outputs = {
    self,
    fu,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (fu.lib) eachSystem mkApp system;
    inherit (import ./lib/exportPackages.nix {inherit inputs;}) exportPackages;

    supportedSystems = with system; [x86_64-linux];
  in
    (eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
        ];
      };
    in {
      # nix run .#<app>
      apps = with (self.packages.${system}); {
        # consensus clients / prysm
        beacon-chain = mkApp {
          name = "beacon-chain";
          drv = prysm;
        };
        validator = mkApp {
          name = "validator";
          drv = prysm;
        };
        client-stats = mkApp {
          name = "client-stats";
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
        mev-boost = mkApp {
          drv = mev-boost;
        };
        mev-geth = mkApp {
          name = "geth";
          drv = mev-geth;
        };
        plugeth = mkApp {
          name = "geth";
          drv = plugeth;
        };

        # utils / ethdo
        ethdo = mkApp {
          drv = ethdo;
        };

        # utils / geth
        abidump = mkApp {
          name = "abidump";
          drv = geth;
        };
        abigen = mkApp {
          name = "abigen";
          drv = geth;
        };
        bootnode = mkApp {
          name = "bootnode";
          drv = geth;
        };
        clef = mkApp {
          name = "clef";
          drv = geth;
        };
        devp2p = mkApp {
          name = "devp2p";
          drv = geth;
        };
        ethkey = mkApp {
          name = "ethkey";
          drv = geth;
        };
        evm = mkApp {
          name = "evm";
          drv = geth;
        };
        faucet = mkApp {
          name = "faucet";
          drv = geth;
        };
        rlpdump = mkApp {
          name = "rlpdump";
          drv = geth;
        };

        # utils / prysm
        keystores = mkApp {
          name = "keystores";
          drv = prysm;
        };
        prysmctl = mkApp {
          name = "prysmctl";
          drv = prysm;
        };
      };

      # nix build .#<app>
      packages = exportPackages pkgs self.overlays;

      # nix flake check
      checks = import ./checks.nix {
        inherit self pkgs;
        selfPkgs = self.packages.${system};
      };

      # generic shell:  nix develop
      # specific shell: nix develop .#<devShells.${system}.default>
      devShells = import ./devshell.nix {
        inherit inputs pkgs;
      };
    }))
    // {
      overlays.default = import ./overlays.nix;
    };
}
