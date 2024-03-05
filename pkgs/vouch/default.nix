{
  buildGoModule,
  fetchFromGitHub,
  mcl,
  bls,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-bPh05Zwe1dY5A6d6JQibqOsB7gNXENfk3aLqBSRqpsw=";
  };

  vendorHash = "sha256-4QD2rVwKOmtvlSzYYf/QEG9ZtILGQnNG2L9ptT6ZKs8=";

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
