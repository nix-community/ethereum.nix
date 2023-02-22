lib: let
  flake = import ./flake.nix lib;
in {
  inherit flake;
}
