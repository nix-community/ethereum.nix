{
  blst,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "mev-boost";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-vzgX9irpI5i85bohppyL5KWQuf71SryRu1gkhWSCVKk=";
  };

  vendorHash = "sha256-xw3xVbgKUIDXu4UQD5CGftON8E4o1u2FcrPo3n6APBE=";

  buildInputs = [blst];

  subPackages = ["cmd/mev-boost"];

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = {
    description = "MEV-Boost allows proof-of-stake Ethereum consensus clients to source blocks from a competitive builder marketplace";
    homepage = "https://github.com/flashbots/mev-boost";
    mainProgram = "mev-boost";
    platforms = ["x86_64-linux"];
  };
}
