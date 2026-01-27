{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "eigenlayer";
  version = "0.13.3";

  src = fetchFromGitHub {
    owner = "Layr-Labs";
    repo = "eigenlayer-cli";
    rev = "v${version}";
    hash = "sha256-8HCoUZHRma4dIIZvIFRkXJl7r73j2stn6fuUj/cQ16g=";
  };

  vendorHash = "sha256-gFWUxC2pTMx3QVbIkqpCrsA2ZTQpal89pEJv11uCMJ8=";

  ldflags = [
    "-s"
    "-w"
  ];
  subPackages = [ "cmd/eigenlayer" ];

  passthru = {
    category = "Staking";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Utility manages core operator functionalities like local key management, operator registration and updates";
    homepage = "https://www.eigenlayer.xyz/";
    license = licenses.bsl11;
    mainProgram = "eigenlayer";
    platforms = [ "x86_64-linux" ];
  };
}
