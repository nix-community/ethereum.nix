{
  buildGoModule,
  fetchFromGitHub,
  mcl,
  bls,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-CpdDt9OHCfYhCX8cdGdkWvdvHxIxTZSYxr1Yk8Mglt8=";
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
