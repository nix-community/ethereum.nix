{
  bls,
  mcl,
  buildGo120Module,
  fetchFromGitHub,
  nix-update-script,
}:
buildGo120Module rec {
  pname = "ssv";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "bloxapp";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-3DTdrxfBZOXAw0nCmVQCEoPXM9/khydvRikOw+9ZXj4=";
  };

  vendorHash = "sha256-pAEJN1Ju4TQRXObbZp9IkPuKOFmFXt1tBgHYwmVT3u4=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/ssvnode"];

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/bloxapp/ssv";
    platforms = ["x86_64-linux"];
    mainProgram = "ssvnode";
  };
}
