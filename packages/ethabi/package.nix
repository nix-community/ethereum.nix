{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "ethabi";
  version = "18.0.0";

  src = fetchFromGitHub {
    owner = "rust-ethereum";
    repo = "ethabi";
    rev = "v${version}";
    hash = "sha256-XZ1/hiOR31k1JcbrDRNvtGUy8mmA1v3eaPYwOJfCcIc=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  # Build only the CLI binary
  cargoBuildFlags = [
    "--package"
    "ethabi-cli"
  ];
  cargoTestFlags = [
    "--package"
    "ethabi-cli"
  ];

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Encode and decode smart contract invocations";
    homepage = "https://github.com/rust-ethereum/ethabi";
    license = licenses.asl20;
    mainProgram = "ethabi";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
