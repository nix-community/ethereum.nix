{ pkgs }:
pkgs.mkShellNoCC {
  packages = [
    pkgs.bash
    pkgs.coreutils
    pkgs.curl
    pkgs.gh
    pkgs.gnugrep
    pkgs.gnused
    pkgs.jq
    pkgs.nix-prefetch-scripts
    pkgs.nix-update
    pkgs.nodejs
  ];

  shellHook = ''
    export PRJ_ROOT=$PWD
  '';
}
