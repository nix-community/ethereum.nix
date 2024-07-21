{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.13.7";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-yv04dsLhHG8hI/xoFMUnJo2UeXDjePuYXHjS0NCnypY=";
  };

  vendorHash = "sha256-dDup2mCx2WcrW5XLpZOe7skWRyQKoQttMb2jrLVnu4E=";

  subPackages = ["rocketpool-cli"];

  postInstall = ''
    mv $out/bin/rocketpool-cli $out/bin/rocketpool
  '';

  meta = {
    description = "Rocket Pool CLI";
    homepage = "https://github.com/rocket-pool/smartnode";
    mainProgram = "rocketpool";
    platforms = ["aarch64-linux" "x86_64-linux"];
  };
}
