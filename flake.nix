{
  description = "ethereum.nix / A reproducible Nix package set for Ethereum clients and utilities";

  nixConfig = {
    extra-substituters = ["https://nix-community.cachix.org"];
    extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  };

  inputs = {
    # packages
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    nixpkgs-2311.url = "github:nixos/nixpkgs/23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    foundry-nix = {
      url = "github:shazow/foundry.nix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # used by dependencies
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    # utils
    systems.url = "github:nix-systems/default";
    devshell = {
      url = "github:numtide/devshell";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat.url = "github:nix-community/flake-compat";
    devour-flake = {
      url = "github:srid/devour-flake";
      flake = false;
    };
    lib-extras = {
      url = "github:aldoborrero/lib-extras/v0.2.2";
      inputs.devshell.follows = "devshell";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    lib-extras,
    systems,
    ...
  }: let
    lib = nixpkgs.lib.extend (l: _: {
      extras = (lib-extras.lib l) // (import ./lib.nix l);
    });
  in
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {inherit lib;};
    }
    {
      imports = [
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule
        ./mkdocs.nix
        ./modules
        ./pkgs
      ];
      systems = import systems;
      perSystem = {
        config,
        pkgs,
        pkgsUnstable,
        pkgs2311,
        system,
        self',
        ...
      }: {
        # pkgs
        _module.args = {
          pkgs = lib.extras.nix.mkNixpkgs {
            inherit system;
            inherit (inputs) nixpkgs;
          };
          pkgsUnstable = lib.extras.nix.mkNixpkgs {
            inherit system;
            nixpkgs = inputs.nixpkgs-unstable;
          };
          pkgs2311 = lib.extras.nix.mkNixpkgs {
            inherit system;
            nixpkgs = inputs.nixpkgs-2311;
          };
        };

        # devshell
        devshells.default = {
          name = "ethereum.nix";
          packages = with pkgsUnstable; [
            nix-update
          ];
          commands = [
            {
              category = "Tools";
              name = "fmt";
              help = "Format the source tree";
              command = "nix fmt";
            }
            {
              category = "Tools";
              name = "check";
              help = "Checks the source tree";
              command = "nix flake check";
            }
          ];
        };

        # formatter
        treefmt.config = {
          projectRootFile = "flake.nix";
          flakeFormatter = true;
          flakeCheck = true;
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
            deno.enable = true;
            mdformat.enable = true;
            statix.enable = true;
          };
          settings.formatter = {
            deno.excludes = [
              "*.md"
              "*.html"
            ];
            mdformat.command = lib.mkDefault (pkgsUnstable.mdformat.withPlugins (p: [
              p.mdformat-admon
              p.mdformat-beautysh
              p.mdformat-footnote
              p.mdformat-frontmatter
              p.mdformat-gfm
              p.mdformat-mkdocs
              p.mdformat-nix-alejandra
              p.mdformat-simple-breaks
              p.mdformat-toc
            ]));
            mdformat.excludes = [
              # mdformat doesn't behave well with some admonitions features
              "apps.md"
              "getting-started.md"
              "index.md"
              "restore-from-backup.md"
            ];
          };
        };

        # checks
        checks =
          {
            # TODO: Restore this check whenever buildbot supports more specific checks
            # nix-build-all = pkgs.writeShellApplication {
            #   name = "nix-build-all";
            #   runtimeInputs = [
            #     pkgs.nix
            #     devour-flake
            #   ];
            #   text = ''
            #     # Make sure that flake.lock is sync
            #     nix flake lock --no-update-lock-file
            #
            #     # Do a full nix build (all outputs)
            #     devour-flake . "$@"
            #   '';
            # };
          }
          # merge in the package derivations to force a build of all packages during a `nix flake check`
          // (with lib; mapAttrs' (n: nameValuePair "package-${n}") (filterAttrs (n: _: ! builtins.elem n ["docs"]) self'.packages))
          # mix in tests
          // config.testing.checks;
      };
    };
}
