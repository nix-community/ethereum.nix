{ pkgs, flake, ... }:
import ../lib/nixos-test.nix {
  inherit pkgs flake;
  name = "mev-boost";
}
