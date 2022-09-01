{pkgs}: let
  # Creates a devshell category paired with a given pkg
  pkgWithCategory = category: package: {inherit package category;};

  # Categories
  formatter = pkgWithCategory "formatters";
  util = pkgWithCategory "utils";
in {
  default = pkgs.devshell.mkShell {
    name = "ethereum.nix";
    packages = with pkgs; [
      alejandra # https://github.com/kamadorueda/alejandra
      just # https://github.com/casey/just
      nix
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
