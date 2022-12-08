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
  util = pkgWithCategory "utils";
in {
  default = devshell.mkShell {
    name = "ethereum.nix";
    packages = with pkgs; [
      just # https://github.com/casey/just
    ];
    commands = with pkgs; [
      (util just)
    ];
  };
}
