{
  fetchFromGitHub,
  pkgs,
  targets ? ["nimbus_beacon_node" "nimbus_validator_client" "gnosis-build" "gnosis-vc-build"],
  stableSystems ? ["x86_64-linux" "aarch64-linux"],
}: let
  version = "25.9.0";
  src = fetchFromGitHub {
    owner = "status-im";
    repo = "nimbus-eth2";
    rev = "v${version}";
    hash = "sha256-DHUPqYMv5navs4I0d4BaQ5Z4hDct8Y07UYekTMm4INw=";
    fetchSubmodules = true;
  };
in
  import "${src}/nix" {inherit pkgs targets stableSystems;}
