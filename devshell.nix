{
  inputs,
  pkgs,
}: let
  inherit (pkgs) system;

  # devshell
  devshell = import inputs.devshell {inherit system;};

  # devshell utilities
  pkgWithCategory = category: package: {inherit package category;};

  # devshell categories
  formatter = pkgWithCategory "formatters";
  util = pkgWithCategory "utils";
in {
  default = devshell.mkShell {
    name = "ethereum.nix";
    packages = with pkgs; [
      alejandra # https://github.com/kamadorueda/alejandra
      just # https://github.com/casey/just
      nodePackages.prettier # https://prettier.io/
      treefmt # https://github.com/numtide/treefmt
    ];
    commands = with pkgs; [
      (formatter alejandra)
      (formatter nodePackages.prettier)
      (util just)
    ];
  };
}
