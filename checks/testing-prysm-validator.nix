{ pkgs, flake, ... }:
import ../lib/nixos-test.nix {
  inherit pkgs flake;
  name = "prysm-validator";
}
