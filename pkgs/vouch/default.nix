{
  callPackage,
  fetchFromGitHub,
  mcl,
  bls,
}: let
  mkVouch = callPackage ./builder.nix {inherit mcl bls;};
in
  mkVouch rec {
    version = "1.7.6";

    src = fetchFromGitHub {
      owner = "attestantio";
      repo = "vouch";
      rev = "v${version}";
      hash = "sha256-zno/8uUkejS0zqOijGZdzknafavbvCU72uj/44on1f8=";
    };

    vendorHash = "sha256-zNHLg/nIKvIbMZtyDANxEQ04dygFHxwrM3JJkD1zcjo=";
  } {}
