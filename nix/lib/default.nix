lib: let
  flakes = import ./flakes.nix lib;
in {
  inherit (flakes) mkApp;
}
