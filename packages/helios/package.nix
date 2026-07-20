{
  fetchFromGitHub,
  lib,
  nix-update-script,
  perl,
  pkg-config,
  openssl,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  pname = "helios";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "a16z";
    repo = "helios";
    rev = version;
    hash = "sha256-PCDQKoF9EbhPdW0/br725RJgcdkPzt9dGXZIYpFSH7g=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "ethereum_hashing-0.7.0" = "sha256-v0fY93t0tFZ/Tb02xKgTI0Z5gMNrXhmKwj3sLW7knpE=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [
    openssl
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Utilities";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "A trustless, efficient, and portable multichain light client";
    homepage = "https://github.com/a16z/helios";
    license = licenses.mit;
    mainProgram = "helios";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
