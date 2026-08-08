{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "nim-lang";
  repo = "csources_v3";
  # NOTE: hardcoded by ethereum.nix
  # nim_csourcesHash in ${src}/vendor/nimbus-build-system/vendor/Nim/config/build_config.txt
  rev = "eeab3ac46e93f10efda8e58c4db02b9438319d71";
  # WARNING: Requires manual updates when Nim compiler version changes.
  hash = "sha256-pTcm2y+HDOuTol8DyoJMOMHsUA6QrgwGdfcOu1NX4PU=";
}
