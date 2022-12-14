{
  clang,
  cmake,
  fetchFromGitHub,
  fetchurl,
  lib,
  llvmPackages,
  openssl,
  protobuf,
  fetchzip,
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

  websignerVersion = "22.8.1";
  websignerSrc = fetchzip {
    url = "https://artifacts.consensys.net/public/web3signer/raw/names/web3signer.zip/versions/${websignerVersion}/web3signer-${websignerVersion}.zip";
    sha256 = "sha256-/iwSW2Es8xpsfvyZ6obVMu6L2U3krnnYAlMH88usnvU=";
    name = "web3signer";
    extension = "zip";
    stripRoot = false;
    postFetch = ''
      mv $out/web3signer-${websignerVersion} $out/web3signer
      echo -n "${websignerVersion}" > $out/version
    '';
  };
in
  rustPlatform.buildRustPackage rec {
    pname = "lighthouse";
    version = "3.3.0";

    src = fetchFromGitHub {
      owner = "sigp";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-py64CWY3k5Z2mm9WduJ4Fh7lQ8b3sF6iIFsYYjndU5I=";
    };

    cargoSha256 = "sha256-0gWTniLkhuPpgdUkE6gpF9uHYT6BeWWgH6Mu7KpFx9w=";

    patches = [./001-Change-Web3Signer-Dir.patch];

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
    LIGHTHOUSE_WEB3SIGNER_BIN = websignerSrc;
    LIGHTHOUSE_WEB3SIGNER_VERSION = "${websignerVersion}";

    # Some tests are failing and we need to know why
    doCheck = false;

    meta = {
      description = "Ethereum consensus client in Rust";
      homepage = "https://github.com/sigp/lighthouse";
    };
  }
