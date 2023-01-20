{
  buildGoModule,
  fetchFromGitHub,
  mcl,
  bls,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-BnANtgOVNTmwlkbXkbInEAMl1ZM6gC/aN5oO0YkHabE=";
  };

  runVend = true;
  vendorSha256 = "sha256-66exSaqELZSo9YAygIRIryCEvE1WErsLTipjb2FH+Gc=";

  buildInputs = [mcl bls];

  doCheck = false;

  meta = {
    description = "An Ethereum 2 multi-node validator client";
    homepage = "https://github.com/attestantio/vouch";
  };
}
