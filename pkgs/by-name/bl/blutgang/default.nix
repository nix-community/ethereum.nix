{
  fetchFromGitHub,
  nix-update-script,
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

  useFetchCargoVendor = true;
  cargoHash = "sha256-kkfIcx8sDQkPWzcTii8NHRq8S8gi+rZYSxaJptEL1QM=";

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "the wd40 of ethereum load balancers";
    homepage = "https://github.com/rainshowerLabs/blutgang";
    mainProgram = "blutgang";
    platforms = ["x86_64-linux"];
  };
}
