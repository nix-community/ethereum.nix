{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "nim-lang";
  repo = "checksums";
  # NOTE: hardcoded by ethereum.nix
  # ChecksumsStableCommit in ${src}/vendor/nimbus-build-system/vendor/Nim/koch.nim
  rev = "0b8e46379c5bc1bf73d8b3011908389c60fb9b98";
  # WARNING: Requires manual updates when Nim compiler version changes.
  hash = "sha256-xC11sD13OTMMUY4F5CrF1XxKSigLtIPt2XQCcQOFNdM=";
}
