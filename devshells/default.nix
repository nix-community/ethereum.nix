{ pkgs }:
pkgs.mkShellNoCC {
  packages = [
    pkgs.nix-prefetch-scripts
    pkgs.nix-update
  ];

  shellHook = ''
    export PRJ_ROOT=$PWD
  '';
}
