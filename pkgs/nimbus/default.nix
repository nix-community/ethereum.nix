{
  applyPatches,
  fetchFromGitHub,
  pkgs,
  targets ? ["nimbus_beacon_node" "nimbus_validator_client"],
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
  import "${src}/nix" {inherit pkgs targets;}
