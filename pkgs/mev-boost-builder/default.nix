{
  blst,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "builder";
  version = "1.11.5-0.3.0";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-5c0a+/dl1/B1PdEMsrUGfjgCE/zZtm6mBNHKBFTyoGc=";
  };

  vendorHash = "sha256-PwsJjcgPXQuOtXDr4NjF7IEk+nrhDBfEnQQyyBFFSjE=";

  buildInputs = [blst];

  subPackages = ["cmd/geth"];

  ldflags = ["-s" "-w"];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Flashbots mev-boost block builder";
    homepage = "https://github.com/flashbots/builder";
    mainProgram = "geth";
    platforms = ["x86_64-linux"];
  };
}
