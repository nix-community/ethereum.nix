{ pkgs, perSystem }:
pkgs.callPackage ./package.nix {
  inherit (perSystem.self) bls_1_86 blst;
}
