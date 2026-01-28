{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "nim-lang";
  repo = "nimble";
  fetchSubmodules = true;
  # NOTE: hardcoded by ethereum.nix
  # NimbleStableCommit in ${src}/vendor/nimbus-build-system/vendor/Nim/koch.nim
  rev = "b1dc28450f028aead0b7cf5da8adf2267db65f89";
  # WARNING: Requires manual updates when Nim compiler version changes.
  hash = "sha256-wgzFhModFkwB8st8F5vSkua7dITGGC2cjoDvgkRVZMs=";
}
