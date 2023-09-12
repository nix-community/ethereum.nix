let
  flake = import ./nix/flake-compat.nix {};
in
  flake.shellNix
