---
title: "Installation"
---

# Installation

Below you'll find several examples of how to use `ethereum.nix`. Choose appropriately depending on if you're using `Nix Flakes` or not.

<details>
  <summary>With flakes without using overlays (recommended)</summary>

```nix title="flake.nix"
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/22.11";
    ethereum-nix = {
      url = "github:nix-community/ethereum.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, ethereum-nix, nixpkgs, ... }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.my-system = nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [
        # optional: add nixos modules via the default nixosModule
        ethereum-nix.nixosModules.${system}.default

        ({pkgs, system, ...}: {
          environment.systemPackages = (with ethereum-nix.packages.${system}; [
            teku
            lighthouse
            # ...
          ]);
        })
      ];
    };
  };
}
```

</details>

<details>
  <summary>With flakes using overlays</summary>

```nix title="flake.nix"
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/22.11";
    ethereum-nix = {
      url = "github:nix-community/ethereum.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, ethereum-nix, nixpkgs, ... }: let
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
        # optional: add nixos modules via the default nixosModule
        ethereum-nix.nixosModules.${system}.default
      ];
    };
  };
}
```

</details>

<details>
  <summary>Without flakes</summary>
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
      # optional: add nixos modules via the default nixosModule
      ethereum-nix.nixosModules.${system}.default
    ];
  };
}
```

1. You must ensure that your `NIX_PATH` has `nixpkgs` pointing to a version that contains nixos modules e.g. `nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-22.11.tar.gz`

</details>
