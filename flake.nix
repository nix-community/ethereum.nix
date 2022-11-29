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
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixlib.url = github:nix-community/nixpkgs.lib;

    # libraries
    fu.url = "github:numtide/flake-utils";
    fup = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "fu";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "fu";
    };
    pre-commit-hooks = {
      url = github:cachix/pre-commit-hooks.nix;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "fu";
    };
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs = {
    self,
    devshell,
    fu,
    fup,
    nixlib,
    nixpkgs,
    ...
  } @ inputs: let
    l = nixlib.lib // fu.lib // {inherit (fup.lib) exportPackages;} // builtins;

    supportedSystems = ["x86_64-linux"];
    mkFlake = f: l.eachSystem supportedSystems f // {overlays.default = import ./overlays.nix;};

    mkPackages = overlay: pkgs: l.exportPackages overlay {inherit pkgs;};
  in (mkFlake (system: let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        devshell.overlay
        self.overlays.default
      ];
    };
  in {
    # nix run .#<app>
    apps = with pkgs; {
      # consensus clients / prysm
      beacon-chain = l.mkApp {
        name = "beacon-chain";
        drv = prysm;
      };
      validator = l.mkApp {
        name = "validator";
        drv = prysm;
      };
      client-stats = l.mkApp {
        name = "client-stats";
        drv = prysm;
      };

      # consensus / teku
      teku = l.mkApp {
        drv = teku;
      };

      # consensus / lighthouse
      lighthouse = l.mkApp {
        drv = lighthouse;
      };

      # execution clients
      besu = l.mkApp {
        drv = besu;
      };
      erigon = l.mkApp {
        drv = erigon;
      };
      geth = l.mkApp {
        drv = geth;
      };
      mev-boost = l.mkApp {
        drv = mev-boost;
      };
      mev-geth = l.mkApp {
        name = "geth";
        drv = mev-geth;
      };
      plugeth = l.mkApp {
        name = "geth";
        drv = plugeth;
      };

      # utils / ethdo
      ethdo = l.mkApp {
        drv = ethdo;
      };

      # utils / geth
      abidump = l.mkApp {
        name = "abidump";
        drv = geth;
      };
      abigen = l.mkApp {
        name = "abigen";
        drv = geth;
      };
      bootnode = l.mkApp {
        name = "bootnode";
        drv = geth;
      };
      clef = l.mkApp {
        name = "clef";
        drv = geth;
      };
      devp2p = l.mkApp {
        name = "devp2p";
        drv = geth;
      };
      ethkey = l.mkApp {
        name = "ethkey";
        drv = geth;
      };
      evm = l.mkApp {
        name = "evm";
        drv = geth;
      };
      faucet = l.mkApp {
        name = "faucet";
        drv = geth;
      };
      rlpdump = l.mkApp {
        name = "rlpdump";
        drv = geth;
      };

      # utils / prysm
      keystores = l.mkApp {
        name = "keystores";
        drv = prysm;
      };
      prysmctl = l.mkApp {
        name = "prysmctl";
        drv = prysm;
      };
    };

    # generic shell:  nix develop
    # specific shell: nix develop .#<devShells.${system}.default>
    devShells = import ./devshell.nix {inherit pkgs;};

    # nix flake check
    checks = import ./checks.nix {
      inherit inputs system;
      packages = self.packages.${system};
    };

    # nix build .#<app>
    packages = mkPackages self.overlays pkgs;
  }));
}
