---
title: "Installation"
---

# Getting Started

This is an experimental project for integrating interesting and important projects in the Ethereum
ecosystem as Nix packages and NixOS modules.

## Installation

### with flakes

```nix title="flake.nix"
{
  inputs = {
    ethereum-nix = {
      url = "github:nix-community/ethereum.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ethereum-nix, nixpkgs }: let
    system = "x86_64-linux";

    pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          # add packages via the default overlay
          ethereum-nix.overlays.default
        ];
    };

  in {
    nixosConfigurations.my-system = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        # add nixos modules via the default nixosModule
        ethereum-nix.nixosModules.${system}.default
      ];
    };
  };
}
```

### without flakes

```nix title="default.nix"
{
  ethereum-nix ? import (fetchTarball "https://github.com/nix-community/ethereum.nix/archive/main.tar.gz"),
  system ? "x86_64-linux",
  pkgs ?
    import <nixpkgs> # (1) {
      inherit system;
      overlays = [
        # add packages via the default overlay
        ethereum-nix.overlays.default
      ];
    },
}: {
  my-machine = pkgs.lib.nixosSystem {
    inherit system pkgs;
    modules = [
      # add nixos modules via the default nixosModule
      ethereum-nix.nixosModules.${system}.default
    ];
  };
}
```

1. You must ensure that your `NIX_PATH` has `nixpkgs` pointing to a version that contains nixos modules e.g. `nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-22.11.tar.gz`
