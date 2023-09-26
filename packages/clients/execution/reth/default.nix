{
  clang,
  lib,
  llvmPackages,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "reth";
  version = "0.1.0-alpha.10";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-koGy06J2sBDY8eW0wG6ikhXEV4OXV1VuAkomIffHeUI=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "c-kzg-0.1.0" = "sha256-a0ZkshWGzChNibsKBBq8HhOtjRYgAuNlSTinZoAFDkY=";
      "discv5-0.3.1" = "sha256-Yl7cNCoBeFh+zBhAiziw0CDFHzoxpL6cVPUzZHpaEqM=";
      "igd-0.12.0" = "sha256-wjk/VIddbuoNFljasH5zsHa2JWiOuSW4VlcUS+ed5YY=";
      "revm-3.3.0" = "sha256-bljQRisFvnGwzPqvYmJIoEQ0hS/veD2oLfzqxcOq/qE=";
    };
  };

  nativeBuildInputs = [clang rustPlatform.bindgenHook];

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
