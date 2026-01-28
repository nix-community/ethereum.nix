{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "nim-lang";
  repo = "csources_v2";
  # NOTE: hardcoded by ethereum.nix
  # nim_csourcesHash in ${src}/vendor/nimbus-build-system/vendor/Nim/config/build_config.txt
  rev = "86742fb02c6606ab01a532a0085784effb2e753e";
  # WARNING: Requires manual updates when Nim compiler version changes.
  hash = "sha256-UCLtoxOcGYjBdvHx7A47x6FjLMi6VZqpSs65MN7fpBs=";
}
