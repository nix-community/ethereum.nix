{
  bls,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "eth2-testnet-genesis";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "protolambda";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-DbmBAf3FxfB6KYfGcmswBUos9P5bwEvpA6+ntev88Wg=";
  };

  vendorHash = "sha256-YGKfJOpzFw9X1z2Q4LyB+0ahEdfv1cJ9fDCzbDFH9Gs=";

  buildInputs = [bls];

  subPackages = ["."];

  ldflags = ["-s" "-w"];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Create a genesis state for an Eth2 testnet";
    homepage = "https://github.com/protolambda/eth2-testnet-genesis";
    mainProgram = "eth2-testnet-genesis";
    platforms = ["x86_64-linux"];
  };
}
