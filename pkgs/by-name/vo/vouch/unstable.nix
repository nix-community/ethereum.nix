{
  buildGoModule,
  fetchFromGitHub,
  mcl,
  bls,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.8.0-beta.3";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-CK6cLXJYMQL+ZRv8bYabgQ0GeDWK8Jcek6d/Wow2LI0=";
  };

  runVend = true;
  vendorHash = "sha256-Mp+RA2L4mOe089ceyKh3m5Q8zLsdwyx6geMFrqbn5Dk=";

  buildInputs = [mcl bls];

  doCheck = false;

  meta = {
    description = "An Ethereum 2 multi-node validator client";
    homepage = "https://github.com/attestantio/vouch";
    mainProgram = "vouch";
    platforms = ["x86_64-linux"];
  };
}
