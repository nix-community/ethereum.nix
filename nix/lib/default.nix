lib: let
  fs = import ./fs.nix lib;
  flake = import ./flake.nix lib;
in {
  inherit fs flake;
}
