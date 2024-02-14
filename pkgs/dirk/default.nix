{
  buildGoModule,
  fetchFromGitHub,
  mcl,
  bls,
  nix-update-script,
}:
buildGoModule rec {
  pname = "dirk";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-IWaAEO2eaqBGkj3TxA9xPDLz5PCYJuUUawCbZ7ZEi8w=";
  };

  runVend = true;
  vendorHash = "sha256-icvKE6I2NrzwykQ13kS4Lo75k9pZ8yUyQLsT/j8KjoY=";

  buildInputs = [mcl bls];

  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = {
    description = "An Ethereum 2 distributed remote keymanager, focused on security and long-term performance of signing operations";
    homepage = "https://github.com/attestantio/dirk";
    mainProgram = "dirk";
    platforms = ["x86_64-linux"];
  };
}
