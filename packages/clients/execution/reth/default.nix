{
  clang,
  lib,
  llvmPackages,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "reth";
  version = "0.1.0-alpha.11";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-llvaN9MNuLuOz5KumKKvRv4yiCfmpnLInNuS9DD48xg=";
  };

  cargoHash = "";
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "discv5-0.3.1" = "sha256-Z/Yl/K6UKmXQ4e0anAJZffV9PmWdBg/ROnNBrB8dABE=";
      "igd-0.12.0" = "sha256-wjk/VIddbuoNFljasH5zsHa2JWiOuSW4VlcUS+ed5YY=";
      "revm-3.5.0" = "sha256-IHKPHvcUqOp4wilygrweadbzMXrNP74J+bpIirJYZyc=";
    };
  };

  nativeBuildInputs = [clang rustPlatform.bindgenHook];

  checkFlags = [
    "--skip=cli::tests::override_trusted_setup_file"
  ];

  # Needed by libmdx
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  meta = {
    description = "Modular, contributor-friendly and blazing-fast implementation of the Ethereum protocol, in Rust";
    homepage = "https://github.com/paradigmxyz/reth";
    license = [lib.licenses.mit lib.licenses.asl20];
    mainProgram = "reth";
    platforms = ["x86_64-linux"];
  };
}
