{
  clang,
  lib,
  llvmPackages,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "reth";
  version = "0.1.0-alpha.2";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-+kGhVL7sIbd3WBaRA6XMTAPMCkxRTRacQKFM8oOCqg0=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    allowBuiltinFetchGit = true;
    outputHashes = {
      "boa_ast-0.16.0" = "sha256-M4tDrKM+cR3Xc7qZQ5uHw7lsMEP6OG/VvyHC2oW0BrI=";
      "discv5-0.3.0" = "sha256-Z1UZY47C2qtEr4WrOEiWynzsiwggOOEy9slZO5n97BM=";
      "igd-0.12.0" = "sha256-wjk/VIddbuoNFljasH5zsHa2JWiOuSW4VlcUS+ed5YY=";
      "revm-3.3.0" = "sha256-jmDzHpbWTXxkv+ATAqYznvcQy8V3EF2XVsCyLaH4p0o=";
      "ruint-1.8.0" = "sha256-OzIUivkNwtox7cMdqv6tkCMsJsGyVeTvfyMr5SZhuPg=";
    };
  };

  nativeBuildInputs = [clang];

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
