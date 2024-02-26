{
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "blutgang";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "rainshowerLabs";
    repo = pname;
    rev = "Blutgang-${version}";
    hash = "sha256-prJq1enn2bJdJieVjvq1vd7dCNBlg5ppymIwjU4pgzg=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-bAHUcfRtefGsRgFMBY5JJ4QSstB8wApcdqz/pqSVpuk=";

  meta = {
    description = "the wd40 of ethereum load balancers";
    homepage = "https://github.com/rainshowerLabs/blutgang";
    mainProgram = "blutgang";
    platforms = ["x86_64-linux"];
  };
}
