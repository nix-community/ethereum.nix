{
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "blutgang";
  version = "0.3.0-canary2";

  src = fetchFromGitHub {
    owner = "rainshowerLabs";
    repo = pname;
    rev = version;
    hash = "sha256-xjDieJgN7BzyCzeKMd3X7dwl/hOnqFPGCtZzlAbVGdI=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-pSdNGmwBCejQbjtfi7YhQmfpoMs9Gxf+6qusD8YSiFc=";

  meta = {
    description = "the wd40 of ethereum load balancers";
    homepage = "https://github.com/rainshowerLabs/blutgang";
    mainProgram = "blutgang";
    platforms = ["x86_64-linux"];
  };
}
