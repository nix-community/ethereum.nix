{
  applyPatches,
  fetchFromGitHub,
  fetchpatch,
  pkgs,
  targets ? ["nimbus_beacon_node" "nimbus_validator_client" "gnosis-build" "gnosis-vc-build"],
  stableSystems ? ["x86_64-linux" "aarch64-linux"],
}: let
  version = "25.9.2";
  src = applyPatches {
    patches = [
      (fetchpatch {
        url = "https://github.com/status-im/nimbus-eth2/commit/0d7c33a479007559d87623e9c14a0f9af3ccf3fe.patch";
        hash = "sha256-VsVgVrGsaIXPrEx9YNtHGsKrXXRczK+FhBJKHMUG3+o=";
      })
      (fetchpatch {
        url = "https://github.com/status-im/nimbus-eth2/pull/7687/commits/b9d82c1fe490151c4cca229b00d576cfe5bd5b91.patch";
        hash = "sha256-reHbZiaFN0V5veVg9fVhgMynpsofBdwmwRrF5psgqUY=";
      })
    ];
    src = fetchFromGitHub {
      owner = "status-im";
      repo = "nimbus-eth2";
      rev = "v${version}";
      hash = "sha256-TriDSV36oUd11m8mS6XruGXaoZuP4hx8a+Csp/qxKRw=";
      fetchSubmodules = true;
    };
  };
in
  import "${src}/nix" {inherit pkgs targets stableSystems;}
