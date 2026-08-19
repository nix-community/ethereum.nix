{
  cmake,
  fetchFromGitHub,
  lib,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  pname = "anchor";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "sigp";
    repo = "anchor";
    rev = "v${version}";
    hash = "sha256-0D+EwxjraTx+qVs/O3xx+PIVHpbfUl3//4O8E7aCdro=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "beacon_node_fallback-0.1.0" = "sha256-MOaXIJRrbaY2qXhoh1wT1ZAFntNZahAHT3C7vT4ZTBg=";
      "libp2p-0.57.0" = "sha256-Ujy81IdJcfF+dUbAvfS3VNKvKOTq91jSlWeTopPnBXs=";
    };
  };

  enableParallelBuilding = true;

  cargoBuildFlags = [ "--package anchor" ];

  buildFeatures = [ "portable" ];

  nativeBuildInputs = [
    cmake
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    sqlite
  ];

  # Use pkg-config to locate the system OpenSSL instead of vendoring it.
  OPENSSL_NO_VENDOR = 1;

  # Workspace tests need network access and fixtures; the version check below
  # exercises the built binary instead.
  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.category = "SSV";

  meta = {
    description = "Rust implementation of the SSV (Secret Shared Validators) protocol";
    homepage = "https://github.com/sigp/anchor";
    license = lib.licenses.asl20;
    mainProgram = "anchor";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
