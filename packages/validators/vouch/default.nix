{
  buildGoModule,
  fetchFromGitHub,
  mcl,
  bls,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-sKjj+7/LnRrEsjhlA+F50s5IZOsqafhY5b2yX3wINPA=";
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
