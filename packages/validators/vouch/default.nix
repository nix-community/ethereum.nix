{
  buildGoModule,
  fetchFromGitHub,
  mcl,
  bls,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-A4ESFBHPIdUXkX/KTppg2qFBPt5zYBPqPVr2Cj1X4HQ=";
  };

  runVend = true;
  vendorSha256 = "sha256-JGcoIhA9FaJvpwIxBhJwCsZ064BYpKG7SjnXu7JMofw=";

  buildInputs = [mcl bls];

  doCheck = false;

  meta = {
    description = "An Ethereum 2 multi-node validator client";
    homepage = "https://github.com/attestantio/vouch";
    platforms = ["x86_64-linux"];
  };
}
