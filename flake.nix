{
  description = "ethereum.nix / A reproducible Nix package set for Ethereum clients and utilities";

  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      blueprintOutputs = inputs.blueprint {
        inherit inputs;
        # nixpkgs 26.11 dropped x86_64-darwin support, so don't target it.
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];
        nixpkgs.config.allowUnfree = true;
      };
    in
    blueprintOutputs
    // {
      overlays.default = import ./overlays {
        inherit (blueprintOutputs) packages;
      };
      nixosModules =
        let
          modules = blueprintOutputs.nixosModules;
          modulePaths = builtins.attrValues modules;
        in
        modules
        // {
          default = {
            imports = modulePaths;
          };
        };
    };
}
