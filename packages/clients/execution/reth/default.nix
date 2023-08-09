{
  clang,
  lib,
  llvmPackages,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "reth";
  version = "0.1.0-alpha.7";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-HVqB+MtUgFixt5H+FwCcUwPxH6rgZrx90C9c6GF9Vrc=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "bindgen-0.64.0" = "sha256-api933laMWajI40cfSDbZkMp1zIagcl2lW1sw+kKv6Y=";
      "boa_ast-0.17.0" = "sha256-tlAJM/SBuT6pyJ54BByZpDx1WTy1PkFfNhmYarFtSEw=";
      "c-kzg-0.1.0" = "sha256-WvZAyKCLz+hLVlGKGsaz6rmPUsDVIZeDX4d7pQCxsFs=";
      "discv5-0.3.1" = "sha256-BqT4ff/NJD4LOv6/yUbM2HddHgympCHL6BNqzxx2rnM=";
      "igd-0.12.0" = "sha256-wjk/VIddbuoNFljasH5zsHa2JWiOuSW4VlcUS+ed5YY=";
      "revm-3.3.0" = "sha256-jmDzHpbWTXxkv+ATAqYznvcQy8V3EF2XVsCyLaH4p0o=";
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
