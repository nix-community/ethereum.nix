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

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    mission-control.url = "github:Platonic-Systems/mission-control";

    # utils
    treefmt-nix.url = "github:numtide/treefmt-nix";
    statix = {
      url = "github:nerdypepper/statix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-update = {
      url = "github:mic92/nix-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }: let
    lib = import ./nix/lib {inherit (nixpkgs) lib;} // nixpkgs.lib;
  in
    (flake-parts.lib.evalFlakeModule
      {
        inherit inputs;
        specialArgs = {
          inherit lib;
          pkgs = nixpkgs.legacyPackages;
        };
      }
      {
        imports = [
          ({inputs', ...}: {
            # make pkgs available to all `perSystem` functions
            _module.args.pkgs = inputs'.nixpkgs.legacyPackages;
            # make custom lib available to all `perSystem` functions
            _module.args.lib = lib;
          })
          ./nix
          ./packages
          ./modules
        ];
        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];
      })
    .config
    .flake;
}
