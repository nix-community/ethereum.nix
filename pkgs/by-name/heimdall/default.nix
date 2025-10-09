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
  version = "30376e47423aeddd40df83b3b08567666e7d01b9";

  src = fetchFromGitHub {
    owner = "jon-becker";
    repo = "${pname}-rs";
    rev = version;
    hash = "sha256-Nx5Z4pd9Pn6jyevGIVO6w6mWZdm7zf+WMEQBXjtr8KQ=";
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
    ++ lib.optionals stdenv.isDarwin [
      apple-sdk
    ];

  # Loads of tests do some kind of I/O incompatible with nix sandbox, but are
  # tested in upstream CI.
  doCheck = false;

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "A toolkit for EVM bytecode analysis";
    homepage = "https://heimdall.rs";
    license = [licenses.mit];
    mainProgram = "heimdall";
    platforms = platforms.unix;
  };
}
