{
  aws-lc,
  cmake,
  fetchFromGitHub,
  fetchurl,
  lib,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
  versionCheckHook,
}:
let
  # deposit_contract's build.rs downloads these ABIs at build time
  depositContractSrc = fetchurl {
    url = "https://raw.githubusercontent.com/ethereum/eth2.0-specs/v0.12.1/deposit_contract/contracts/validator_registration.json";
    hash = "sha256-ZslAe1wkmkg8Tua/AmmEfBmjqMVcGIiYHwi+WssEwa8=";
  };
  depositContractTestnetSrc = fetchurl {
    url = "https://raw.githubusercontent.com/sigp/unsafe-eth2-deposit-contract/v0.9.2.1/unsafe_validator_registration.json";
    hash = "sha256-aeTeHRT3QtxBRSNMCITIWmx89vGtox2OzSff8vZ+RYY=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "anchor";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "sigp";
    repo = "anchor";
    rev = "v${version}";
    hash = "sha256-XOzM7DwVBPkSwX09C3epw+23WhtZ6ku5Zqy4djuU8Ds=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "account_utils-0.1.0" = "sha256-EFt8cwC2NrM/Med0qOuyDvZlRxzk4pmch4f49CqOEPs=";
      "ethereum_ssz-0.10.4" = "sha256-mnoExiIEiurjK2F1C4BRe7ATqO3n53yhuZjLd5hqpS0=";
      "libp2p-0.57.0" = "sha256-Gu+kFyxlV7FsH8+GRP3POlGVMvm2ZN94tlBc15ZlP5g=";
      "milhouse-0.9.0" = "sha256-pcoXhOkqjypqwyiDHB5E/dTwy01GBhD/ze+vt90u1qM=";
      "ssz_types-0.14.1" = "sha256-S1KL21Lc0eFaYB4Ehlrpy9tj2rU+iNR6ELx2nuCJa+g=";
      "tree_hash-0.12.1" = "sha256-pUbQkTm/P4bC63E9gNIksV3rhbr6TvIOS9uU61lCK2Y=";
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
    aws-lc
    openssl
    sqlite
  ];

  # Use pkg-config to locate the system OpenSSL instead of vendoring it.
  OPENSSL_NO_VENDOR = 1;

  # deposit_contract's build.rs would otherwise download the ABIs (no network in sandbox)
  LIGHTHOUSE_DEPOSIT_CONTRACT_SPEC_URL = "file:${depositContractSrc}";
  LIGHTHOUSE_DEPOSIT_CONTRACT_TESTNET_URL = "file:${depositContractTestnetSrc}";

  # Workspace tests need network access and fixtures; the version check below
  # exercises the built binary instead.
  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.category = "SSV";

  meta = {
    description = "Rust implementation of the SSV (Secret Shared Validators) protocol";
    homepage = "https://github.com/sigp/anchor";
    changelog = "https://github.com/sigp/anchor/releases";
    license = lib.licenses.asl20;
    mainProgram = "anchor";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
