{
  description = "ethereum.nix / A reproducible Nix package set for Ethereum clients and utilities";

  nixConfig = {
    extra-substituters = ["https://nix-community.cachix.org"];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # packages
    nixpkgs.url = "github:nixos/nixpkgs/25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    foundry-nix = {
      url = "github:shazow/foundry.nix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # flake-parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    # used by dependencies
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    # utils
    systems.url = "github:nix-systems/default";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    systems,
    ...
  }: let
    lib = nixpkgs.lib.extend (l: _: (import ./lib.nix l));
  in
    flake-parts.lib.mkFlake
    {
      inherit inputs;
      specialArgs = {inherit lib;};
    }
    {
      imports = [
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule
        ./modules
        ./pkgs
      ];
      systems = import systems;
      perSystem = {
        config,
        pkgs,
        pkgsUnstable,
        system,
        self',
        ...
      }: {
        # pkgs
        _module.args = {
          pkgs = lib.mkNixpkgs {
            inherit system;
            inherit (inputs) nixpkgs;
          };
          pkgsUnstable = lib.mkNixpkgs {
            inherit system;
            nixpkgs = inputs.nixpkgs-unstable;
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
            mdformat.package = lib.mkDefault (
              pkgs.mdformat.withPlugins (p: [
                p.mdformat-admon
                p.mdformat-beautysh
                p.mdformat-footnote
                p.mdformat-frontmatter
                p.mdformat-gfm
                p.mdformat-mkdocs
                p.mdformat-nix-alejandra
                p.mdformat-simple-breaks
                # TODO: now it's broken, return after fix
                # p.mdformat-toc
              ])
            );
            mdformat.excludes = [
              # mdformat doesn't behave well with some admonitions features
              "docs/apps.md"
              "docs/getting-started.md"
              "docs/index.md"
              "docs/nixos/restore-from-backup.md"
            ];
          };
        };

        # checks
        checks =
          # merge in the package derivations to force a build of all packages during a `nix flake check`
          (
            with lib;
              mapAttrs' (n: nameValuePair "package-${n}") (
                filterAttrs (n: _: !builtins.elem n ["docs"]) self'.packages
              )
          )
          # mix in tests
          // config.testing.checks;
      };
    };
}
