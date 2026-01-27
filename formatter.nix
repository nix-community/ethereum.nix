{ pkgs, inputs, ... }:
let
  treefmt-settings = {
    projectRootFile = "flake.nix";
    programs = {
      # nix
      nixfmt.enable = true;
      deadnix.enable = true;
      statix.enable = true;

      # shell
      shellcheck.enable = true;
      shfmt.enable = true;

      # markdown
      mdformat.enable = true;
    };
    settings.formatter = {
      # nix
      deadnix.pipeline = "nix";
      deadnix.priority = 1;
      statix.pipeline = "nix";
      statix.priority = 2;
      nixfmt.pipeline = "nix";
      nixfmt.priority = 3;

      # shell
      shellcheck.pipeline = "shell";
      shellcheck.priority = 1;
      shfmt.pipeline = "shell";
      shfmt.priority = 2;

      # markdown
      mdformat.package = pkgs.lib.mkDefault (
        pkgs.mdformat.withPlugins (p: [
          p.mdformat-beautysh
          p.mdformat-footnote
          p.mdformat-frontmatter
          p.mdformat-gfm
        ])
      );
    };
  };
in
inputs.treefmt-nix.lib.mkWrapper pkgs treefmt-settings
