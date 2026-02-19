{ pkgs, perSystem, ... }:
pkgs.callPackage ./package.nix {
  inherit (perSystem.self) foundry svm-lists;
}
