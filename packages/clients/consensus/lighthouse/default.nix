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
  postgresql,
  foundry,
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
in
  rustPlatform.buildRustPackage rec {
    pname = "lighthouse";
    version = "4.4.1";

    src = fetchFromGitHub {
      owner = "sigp";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-swwoqvmLRVmi74W7Kty+9YwZFPysIG7GZM0mwy57b6M=";
    };

    cargoSha256 = "sha256-KlTQF1iL2PYAk+nmQIm72guy2PxGkN/YzhgCNv1FZGM=";
    cargoLock = {
      lockFile = "${src}/Cargo.lock";
      outputHashes = {
        "amcl-0.3.0" = "sha256-Mj4dXTlGVSleFfuTKgVDQ7S3jANMsdtVE5L90WGxA4U=";
        "anvil-rpc-0.1.0" = "sha256-L38OioxnWEn94g3GJT4j3U1cJZ8jQDHp8d1QOHaVEuU=";
        "beacon-api-client-0.1.0" = "sha256-Z0CoPxZzl2bjb8vgmHWxq2orMawhMMs7beKGopilKjE=";
        "ethereum-consensus-0.1.1" = "sha256-biTrw3yMJUo9+56QK5RGWXLCoPPZEWp18SCs+Y9QWg4=";
        "libmdbx-0.1.4" = "sha256-NMsR/Wl1JIj+YFPyeMMkrJFfoS07iEAKEQawO89a+/Q=";
        "lmdb-rkv-0.14.0" = "sha256-sxmguwqqcyOlfXOZogVz1OLxfJPo+Q0+UjkROkbbOCk=";
        "mev-rs-0.3.0" = "sha256-LCO0GTvWTLcbPt7qaSlLwlKmAjt3CIHVYTT/JRXpMEo=";
        "testcontainers-0.14.0" = "sha256-mSsp21G7MLEtFROWy88Et5s07PO0tjezovCGIMh+/oQ=";
        "warp-0.3.5" = "sha256-jpZCIhbhxAhrWP8sC2wC7mg44uaPfTSrHVi8brs+4dc=";
      };
    };

    cargoBuildFlags = ["--package lighthouse"];

    nativeBuildInputs = [cmake clang];
    buildInputs = [openssl protobuf];

    buildNoDefaultFeatures = true;
    buildFeatures = ["modern" "slasher-mdbx"];

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

    cargoTestFlags = [
      "--workspace"
      "--exclude beacon_node"
      "--exclude http_api"
      "--exclude beacon_chain"
      "--exclude lighthouse"
      "--exclude lighthouse_network"
      "--exclude slashing_protection"
      "--exclude watch"
      "--exclude web3signer_tests"
    ];

    nativeCheckInputs = [
      postgresql
      foundry
    ];

    checkFeatures = [];

    # All of these tests require network access
    checkFlags = [
      "--skip service::tests::tests::test_dht_persistence"
      "--skip time::test::test_reinsertion_updates_timeout"
    ];

    meta = {
      description = "Ethereum consensus client in Rust";
      homepage = "https://github.com/sigp/lighthouse";
      mainProgram = "lighthouse";
      platforms = ["x86_64-linux"];
    };
  }
