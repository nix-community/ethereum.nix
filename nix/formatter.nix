{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: let
    nixpkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};

    mdformat-custom = nixpkgs-unstable.python3Packages.mdformat.withPlugins (with nixpkgs-unstable.python3Packages; [
      mdformat-admon
      mdformat-beautysh
      mdformat-footnote
      mdformat-frontmatter
      mdformat-gfm
      mdformat-mkdocs
      mdformat-nix-alejandra
      mdformat-simple-breaks
      mdformat-toc
    ]);
  in {
    treefmt.config = {
      inherit (config.flake-root) projectRootFile;
      package = pkgs.treefmt;
      flakeFormatter = true;
      programs = {
        alejandra.enable = true;
        deadnix.enable = true;
        prettier.enable = true;
        mdformat.enable = true;
        mdformat.package = mdformat-custom;
      };
      settings.formatter.prettier.excludes = ["*.md"];
    };

    devshells.default.packages = [
      pkgs.alejandra
      mdformat-custom
    ];

    devshells.default.commands = [
      {
        category = "Tools";
        name = "fmt";
        help = "Format the source tree";
        command = "nix fmt";
      }
    ];
  };
}
