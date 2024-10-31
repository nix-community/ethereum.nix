{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "eigenlayer";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "Layr-Labs";
    repo = "eigenlayer-cli";
    rev = "v${version}";
    hash = "sha256-cr3ltNmJj8GoQLADivekLU2hV7xWk4KR2Gej0rcaVTA=";
  };

  vendorHash = "sha256-VcXjYiJ9nwSCQJvQd7UYduZKJISRfoEXjziiX6Z3w6Q=";

  ldflags = ["-s" "-w"];
  subPackages = ["cmd/eigenlayer"];

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = with lib; {
    description = "Utility manages core operator functionalities like local key management, operator registration and updates";
    homepage = "https://www.eigenlayer.xyz/";
    license = licenses.bsl11;
    mainProgram = "eigenlayer";
    platforms = ["x86_64-linux"];
  };
}
