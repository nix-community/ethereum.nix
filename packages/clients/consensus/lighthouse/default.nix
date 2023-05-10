{
  clang,
  cmake,
  fetchFromGitHub,
  fetchurl,
  lib,
  llvmPackages,
  openssl,
  protobuf,
  rustPlatform,
}: let
  slasherContractVersion = "0.12.1";
  slasherContractSrc = fetchurl {
    url = "https://raw.githubusercontent.com/ethereum/eth2.0-specs/v${slasherContractVersion}/deposit_contract/contracts/validator_registration.json";
    sha256 = "sha256-ZslAe1wkmkg8Tua/AmmEfBmjqMVcGIiYHwi+WssEwa8=";
  };

  slasherContractTestVersion = "0.9.2.1";
  slasherContractTestnetSrc = fetchurl {
    url = "https://raw.githubusercontent.com/sigp/unsafe-eth2-deposit-contract/v${slasherContractTestVersion}/unsafe_validator_registration.json";
    sha256 = "sha256-aeTeHRT3QtxBRSNMCITIWmx89vGtox2OzSff8vZ+RYY=";
  };
  # TODO: need to make a PR to lighthouse to make possible to set a path to web3signer externally.
  # websignerVersion = "23.3.1";
  # websignerSrc = fetchzip {
  #   url = "https://artifacts.consensys.net/public/web3signer/raw/names/web3signer.zip/versions/${websignerVersion}/web3signer-${websignerVersion}.zip";
  #   sha256 = "sha256-oIm45A0BgFyAwd4g7qzdBMNxoeDuFvPHyG2/65wWecI=";
  #   name = "web3signer";
  #   extension = "zip";
  #   stripRoot = false;
  #   postFetch = ''
  #     mv $out/web3signer-${websignerVersion} $out/web3signer
  #     echo -n "${websignerVersion}" > $out/version
  #   '';
  # };
in
  rustPlatform.buildRustPackage rec {
    pname = "lighthouse";
    version = "4.1.0";

    src = fetchFromGitHub {
      owner = "sigp";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-QVAFzV9sao8+eegI7bLfm+pPHyvDFhnADS80+nqqgtE=";
    };

    cargoSha256 = "sha256-KlTQF1iL2PYAk+nmQIm72guy2PxGkN/YzhgCNv1FZGM=";
    cargoLock = {
      lockFile = "${src}/Cargo.lock";
      outputHashes = {
        "amcl-0.3.0" = "sha256-Mj4dXTlGVSleFfuTKgVDQ7S3jANMsdtVE5L90WGxA4U=";
        "arbitrary-1.3.0" = "sha256-BMxcBfxBRf+Kb0Tz55jtFbwokSeD2GPtB+KV8Wbne0g=";
        "beacon-api-client-0.1.0" = "sha256-fI8qST6HZrchg7yr/nVtRNrsW3f5ONSX+mGRYW+iiqA=";
        "ethereum-consensus-0.1.1" = "sha256-aBrZ786Me0BWpnncxQc5MT3r+O0yLQhqGKFBiNTdqSA=";
        "libmdbx-0.1.4" = "sha256-NMsR/Wl1JIj+YFPyeMMkrJFfoS07iEAKEQawO89a+/Q=";
        "lmdb-rkv-0.14.0" = "sha256-sxmguwqqcyOlfXOZogVz1OLxfJPo+Q0+UjkROkbbOCk=";
        "mev-rs-0.2.1" = "sha256-n3ns1oynw5fKQtp/CQHER41+C1EmLCVEBqggkHc3or4=";
        "ssz-rs-0.8.0" = "sha256-k1JLu+jZrSqUyHou76gbJeA5CDWwdL0fPkek3Vzl4Gs=";
        "warp-0.3.2" = "sha256-m9lkEgeSs0yEc+6N6DG7IfQY/evkUMoNyst2hMUR//c=";
      };
    };

    cargoBuildFlags = [
      "--package lighthouse"
    ];

    buildNoDefaultFeatures = true;
    buildFeatures = ["modern" "slasher-mdbx"];

    nativeBuildInputs = [cmake clang];
    buildInputs = [openssl protobuf];

    # Needed to get openssl-sys to use pkg-config.
    OPENSSL_NO_VENDOR = 1;
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    OPENSSL_DIR = "${lib.getDev openssl}";

    # Needed to get prost-build to use protobuf
    PROTOC = "${protobuf}/bin/protoc";

    # Needed by libmdx
    LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

    # common crate tries to fetch the compiled version from an URL
    # see: https://github.com/sigp/lighthouse/blob/stable/common/deposit_contract/build.rs#L30
    LIGHTHOUSE_DEPOSIT_CONTRACT_SPEC_URL = "file:${slasherContractSrc}";

    # common crate tries to fetch the compiled version from an URL
    # see: https://github.com/sigp/lighthouse/blob/stable/common/deposit_contract/build.rs#L33
    LIGHTHOUSE_DEPOSIT_CONTRACT_TESTNET_URL = "file:${slasherContractTestnetSrc}";

    # web3signer_tests crate will try to download form Github
    # see: https://github.com/sigp/lighthouse/blob/stable/testing/web3signer_tests/build.rs
    # and https://github.com/sigp/lighthouse/blob/stable/testing/web3signer_tests/src/lib.rs
    # LIGHTHOUSE_WEB3SIGNER_BIN = websignerSrc;
    # LIGHTHOUSE_WEB3SIGNER_VERSION = "${websignerVersion}";

    # TODO: Some tests are failing and we need to know why
    doCheck = false;

    meta = {
      description = "Ethereum consensus client in Rust";
      homepage = "https://github.com/sigp/lighthouse";
      mainProgram = "lighthouse";
      platforms = ["x86_64-linux"];
    };
  }
