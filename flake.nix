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
    fup = {
      url = github:gytis-ivaskevicius/flake-utils-plus;
      inputs.flake-utils.follows = "fu";
    };
    devshell = {
      url = github:numtide/devshell;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "fu";
    };
  };

  outputs = {
    self,
    devshell,
    fu,
    fup,
    nixpkgs,
    ...
  } @ inputs: let
    lib = nixpkgs.lib // fu.lib // {inherit (fup.lib) exportPackages;} // builtins;

    supportedSystems = ["x86_64-linux"];
    mkFlake = f: lib.eachSystem supportedSystems f // {overlays.default = import ./overlays.nix;};

    mkPackages = overlay: pkgs: lib.exportPackages overlay {inherit pkgs;};
  in (mkFlake (system: let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        self.overlays.default
      ];
    };
  in {
    # nix run .#<app>
    apps = with pkgs; {
      # consensus clients / prysm
      beacon-chain = lib.mkApp {
        name = "beacon-chain";
        drv = prysm;
      };
      validator = lib.mkApp {
        name = "validator";
        drv = prysm;
      };
      client-stats = lib.mkApp {
        name = "client-stats";
        drv = prysm;
      };

      # consensus / teku
      teku = lib.mkApp {
        drv = teku;
      };

      # consensus / lighthouse
      lighthouse = lib.mkApp {
        drv = lighthouse;
      };

      # execution clients
      besu = lib.mkApp {
        drv = besu;
      };
      erigon = lib.mkApp {
        drv = erigon;
      };
      geth = lib.mkApp {
        drv = geth;
      };
      mev-boost = lib.mkApp {
        drv = mev-boost;
      };
      mev-geth = lib.mkApp {
        name = "geth";
        drv = mev-geth;
      };
      plugeth = lib.mkApp {
        name = "geth";
        drv = plugeth;
      };

      # utils / ethdo
      ethdo = lib.mkApp {
        drv = ethdo;
      };

      # utils / geth
      abidump = lib.mkApp {
        name = "abidump";
        drv = geth;
      };
      abigen = lib.mkApp {
        name = "abigen";
        drv = geth;
      };
      bootnode = lib.mkApp {
        name = "bootnode";
        drv = geth;
      };
      clef = lib.mkApp {
        name = "clef";
        drv = geth;
      };
      devp2p = lib.mkApp {
        name = "devp2p";
        drv = geth;
      };
      ethkey = lib.mkApp {
        name = "ethkey";
        drv = geth;
      };
      evm = lib.mkApp {
        name = "evm";
        drv = geth;
      };
      faucet = lib.mkApp {
        name = "faucet";
        drv = geth;
      };
      rlpdump = lib.mkApp {
        name = "rlpdump";
        drv = geth;
      };

      # utils / prysm
      keystores = lib.mkApp {
        name = "keystores";
        drv = prysm;
      };
      prysmctl = lib.mkApp {
        name = "prysmctl";
        drv = prysm;
      };
    };

    # generic shell:  nix develop
    # specific shell: nix develop .#<devShells.${system}.default>
    devShells = import ./devshell.nix {inherit pkgs inputs;};

    # nix flake check
    checks = import ./checks.nix {
      inherit self inputs system pkgs;
      packages = self.packages.${system};
    };

    # nix build .#<app>
    packages = mkPackages self.overlays pkgs;
  }));
}
