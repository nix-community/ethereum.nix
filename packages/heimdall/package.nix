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
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "jon-becker";
    repo = "${pname}-rs";
    rev = version;
    hash = "sha256-xdcCo8hmrnXExZhwc3GwnSxDqmArrwbnIvNmN+N+/tY=";
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
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
