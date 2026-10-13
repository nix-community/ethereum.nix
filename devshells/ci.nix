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
    pkgs.python3
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.bubblewrap ];

  shellHook = ''
    export PRJ_ROOT=$PWD
  '';
}
