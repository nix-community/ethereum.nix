{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "eigenlayer";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "Layr-Labs";
    repo = "eigenlayer-cli";
    rev = "v${version}";
    hash = "sha256-zLTzDVXj2XTjgMuTLXVQStzDkkOGU2kCgIvBmJKohY4";
  };

  vendorHash = "sha256-gAW+yEj4aRHTuuZLrqQs8lebs9/O0uGxkHRK3B1TG+Q=";

  ldflags = ["-s" "-w"];
  subPackages = ["cmd/eigenlayer"];

  meta = with lib; {
    description = "Utility manages core operator functionalities like local key management, operator registration and updates";
    homepage = "https://www.eigenlayer.xyz/";
    license = licenses.bsl11;
    mainProgram = "eigenlayer";
    platforms = ["x86_64-linux"];
  };
}
