{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "nim-lang";
  repo = "nimble";
  fetchSubmodules = true;
  # NOTE: hardcoded by ethereum.nix
  # NimbleStableCommit in ${src}/vendor/nimbus-build-system/vendor/Nim/koch.nim
  rev = "a399f502dec7ffcd905c1cf54b13274ad990bada";
  # WARNING: Requires manual updates when Nim compiler version changes.
  hash = "sha256-39d9EsS0opz6vQzSE91gBRQbaTPeebVQLf/QdJoaD8o=";
}
