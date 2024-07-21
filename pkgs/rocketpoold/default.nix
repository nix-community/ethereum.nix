{
  bls,
  blst,
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

  buildInputs = [bls blst];

  subPackages = ["rocketpool"];

  CGO_CFLAGS = "-O -D__BLST_PORTABLE__";
  CGO_ENABLED = 1;
  postInstall = ''
    mv $out/bin/rocketpool $out/bin/rocketpoold
  '';

  meta = {
    description = "Rocket Pool Daemon";
    homepage = "https://github.com/rocket-pool/smartnode";
    mainProgram = "rocketpoold";
    platforms = ["aarch64-linux" "x86_64-linux"];
  };
}
