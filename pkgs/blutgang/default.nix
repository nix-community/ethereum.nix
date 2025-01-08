{
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "blutgang";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "rainshowerLabs";
    repo = pname;
    rev = "Blutgang-${version}";
    hash = "sha256-EAmmCvESMneYuoTEa8Qm5eYqJkkRDY8CqlfsER1Pq8s=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-1G80j/lZrAlrgOLgpKyGYP9x6g/9kxXf3wmY2OcynFc=";

  meta = {
    description = "the wd40 of ethereum load balancers";
    homepage = "https://github.com/rainshowerLabs/blutgang";
    mainProgram = "blutgang";
    platforms = ["x86_64-linux"];
  };
}
