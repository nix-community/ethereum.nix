{
  darwin,
  fetchFromGitHub,
  lib,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
}:
rustPlatform.buildRustPackage rec {
  pname = "heimdall";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "jon-becker";
    repo = "${pname}-rs";
    rev = version;
    hash = "sha256-E3WFJ+1ps5UiA+qzJAjouBR4wJbzxrJfvcW6Kany/jU=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      Security
      SystemConfiguration
    ]);

  # Loads of tests do some kind of I/O incompatible with nix sandbox, but are
  # tested in upstream CI.
  doCheck = false;

  meta = with lib; {
    description = "A toolkit for EVM bytecode analysis";
    homepage = "https://heimdall.rs";
    license = [licenses.mit];
    mainProgram = "heimdall";
    platforms = platforms.unix;
  };
}
