{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "nim-lang";
  repo = "nimble";
  fetchSubmodules = true;
  # NOTE: hardcoded by ethereum.nix
  # NimbleStableCommit in ${src}/vendor/nimbus-build-system/vendor/Nim/koch.nim
  rev = "aa03f886e4a111d6af9090c6a1f1271d64b66f7b";
  # WARNING: Requires manual updates when Nim compiler version changes.
  hash = "sha256-PoEJKD24BNOc70DwGlLaPmo48WeEC9nOHy8etkXRUMQ=";
}
