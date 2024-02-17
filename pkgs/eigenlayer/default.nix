{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "eigenlayer";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "Layr-Labs";
    repo = "eigenlayer-cli";
    rev = "v${version}";
    hash = "sha256-PN1VB01NyBrDNIDpUIQlzhdwKoy17X1GdfQfRrN3bWo=";
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
