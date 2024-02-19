{
  callPackage,
  fetchFromGitHub,
  mcl,
  bls,
}: let
  mkVouch = callPackage ./builder.nix {inherit mcl bls;};
in
  mkVouch rec {
    version = "1.8.0-beta.3";

    src = fetchFromGitHub {
      owner = "attestantio";
      repo = "vouch";
      rev = "v${version}";
      hash = "sha256-CK6cLXJYMQL+ZRv8bYabgQ0GeDWK8Jcek6d/Wow2LI0=";
    };

    vendorHash = "sha256-Mp+RA2L4mOe089ceyKh3m5Q8zLsdwyx6geMFrqbn5Dk=";
  } {}
