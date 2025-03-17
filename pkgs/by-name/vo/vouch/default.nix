{
  buildGoModule,
  fetchFromGitHub,
  mcl,
  bls,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-1FH4H4iH5uc7nUYVlQdqwYylB9puNJ557LLgy3ovcRI=";
  };

  vendorHash = "sha256-h5MQ3v3YLKxyOK16wb/p8ND68P5LaugWiIXXG8mtXqE=";

  runVend = true;

  buildInputs = [mcl bls];

  doCheck = false;

  meta = {
    description = "An Ethereum 2 multi-node validator client";
    homepage = "https://github.com/attestantio/vouch";
    mainProgram = "vouch";
    platforms = ["x86_64-linux"];
  };
}
