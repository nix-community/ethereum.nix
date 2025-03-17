{
  applyPatches,
  fetchFromGitHub,
  pkgs,
  targets ? ["nimbus_beacon_node" "nimbus_validator_client" "gnosis-build" "gnosis-vc-build"],
  stableSystems ? ["x86_64-linux" "aarch64-linux"],
}: let
  version = "24.12.0";
  src = applyPatches {
    src = fetchFromGitHub {
      owner = "status-im";
      repo = "nimbus-eth2";
      rev = "v${version}";
      hash = "sha256-DBvsnGr91a69eCj1hAeoVOpxas5rfaT36rIxWEmvIVg=";
      fetchSubmodules = true;
    };
    patches = [./fix-hash.patch];
  };
in
  import "${src}/nix" {inherit pkgs targets stableSystems;}
