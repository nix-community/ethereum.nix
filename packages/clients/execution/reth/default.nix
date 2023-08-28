{
  clang,
  lib,
  llvmPackages,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "reth";
  version = "0.1.0-alpha.8";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-fQY2tW8pzFjA5UXwC71On4MKffd/ERYjhHIxNd+JWFQ=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "bindgen-0.64.0" = "sha256-api933laMWajI40cfSDbZkMp1zIagcl2lW1sw+kKv6Y=";
      "boa_ast-0.17.0" = "sha256-56QzQF4BRuRx7ZzJXeYsjdkrKaoOFWJyYjQQwdp5gaE=";
      "c-kzg-0.1.0" = "sha256-qj8S4zaH42nO2wS6K6ME9wgd4zmUWareQ+ABHyTifLw=";
      "discv5-0.3.1" = "sha256-Yl7cNCoBeFh+zBhAiziw0CDFHzoxpL6cVPUzZHpaEqM=";
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
