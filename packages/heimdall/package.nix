{
  apple-sdk,
  fetchFromGitHub,
  lib,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
}:
rustPlatform.buildRustPackage rec {
  pname = "heimdall";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "jon-becker";
    repo = "${pname}-rs";
    rev = version;
    hash = "sha256-5QTx//vATsvVRBYmDCSUqmbVkNr3depTd/pNhUgjWG4=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.isDarwin [
    apple-sdk
  ];

  # Loads of tests do some kind of I/O incompatible with nix sandbox, but are
  # tested in upstream CI.
  doCheck = false;

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "A toolkit for EVM bytecode analysis";
    homepage = "https://heimdall.rs";
    license = [ licenses.mit ];
    mainProgram = "heimdall";
    platforms = platforms.unix;
  };
}
