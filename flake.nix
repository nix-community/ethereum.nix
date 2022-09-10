{
  description = "A reproducible Nix package set for Ethereum clients and utilities";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://pre-commit-hooks.cachix.org"
      "https://ethereum-nix.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "ethereum-nix.cachix.org-1:mpmQuO1myAs3CXDBLh8uQy4QDFtemaDKLD4UKmVjByE="
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
      # consensus clients
      beacon-chain = l.mkApp {
        name = "beacon-chain";
        drv = prysm;
      };
      client-stats = l.mkApp {
        name = "client-stats";
        drv = prysm;
      };
      validator = l.mkApp {
        name = "validator";
        drv = prysm;
      };
      teku = l.mkApp {
        drv = teku;
      };
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

      # utils
      ethdo = l.mkApp {
        drv = ethdo;
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
