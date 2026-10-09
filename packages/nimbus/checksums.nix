{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "nim-lang";
  repo = "checksums";
  # NOTE: hardcoded by ethereum.nix
  # ChecksumsStableCommit in ${src}/vendor/nimbus-build-system/vendor/Nim/koch.nim
  rev = "5c132cd332cce5d64a0da9ac3e4c9664313dccb4";
  # WARNING: Requires manual updates when Nim compiler version changes.
  hash = "sha256-EwGpWSzWeEt8KLracRUle8KFb/2c6Ndz1Sqm3FhBvRY=";
}
