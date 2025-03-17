{
  bls,
  buildGo120Module,
  fetchFromGitHub,
  lib,
  mcl,
  nix-update-script,
}:
buildGo120Module rec {
  pname = "ssv-dkg";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "ssvlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-PXqjLvX9ewYtrOb3TDeNfuMxHamS1b6fh61FLAV2srE=";
  };

  vendorHash = "sha256-NtZRe8ldkYU2TXZQMEJ0bZyH44ZOknNdZON3cZhMOmg=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/ssv-dkg"];

  ldflags = ["-X main.Version=v${version}"];

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "The ssv-dkg tool enable operators to participate in ceremonies to generate distributed validator keys for Ethereum stakers.";
    homepage = "https://github.com/ssvlabs/ssv-dkg";
    license = with licenses; [gpl3Plus];
    mainProgram = "ssv-dkg";
    platforms = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
  };
}
