{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.7.6";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-zno/8uUkejS0zqOijGZdzknafavbvCU72uj/44on1f8=";
  };

  runVend = true;
  vendorHash = "sha256-zNHLg/nIKvIbMZtyDANxEQ04dygFHxwrM3JJkD1zcjo=";

  buildInputs = [mcl bls];

  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = {
    description = "An Ethereum 2 multi-node validator client";
    homepage = "https://github.com/attestantio/vouch";
    mainProgram = "vouch";
    platforms = ["x86_64-linux"];
  };
}
