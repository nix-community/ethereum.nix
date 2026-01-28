{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "nim-lang";
  repo = "checksums";
  # NOTE: hardcoded by ethereum.nix
  # ChecksumsStableCommit in ${src}/vendor/nimbus-build-system/vendor/Nim/koch.nim
  rev = "f8f6bd34bfa3fe12c64b919059ad856a96efcba0";
  # WARNING: Requires manual updates when Nim compiler version changes.
  hash = "sha256-JZhWqn4SrAgNw/HLzBK0rrj3WzvJ3Tv1nuDMn83KoYY=";
}
