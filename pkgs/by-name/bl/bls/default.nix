{
  clang,
  cmake,
  fetchFromGitHub,
  gmp,
  lib,
  nix-update-script,
  stdenv,
  system,
}:
stdenv.mkDerivation rec {
  pname = "bls";
  version = "1.86";

  src = fetchFromGitHub {
    owner = "herumi";
    repo = "bls";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-VIJi8sjDq40ecPnEWzFPDR2t5rCOUIWxfI4QAemfPPM=";
  };

  nativeBuildInputs = [cmake] ++ (lib.optionals (system == "aarch64-linux") [clang]);
  cmakeFlags = lib.optionals (system == "aarch64-linux") [
    "-DCMAKE_CXX_COMPILER=clang++"
    "-DCMAKE_CXX_COMPILER_ID=Clang"
  ];

  buildInputs = [gmp];

  # ETH2.0 spec
  CFLAGS = [''-DBLS_ETH''];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "BLS threshold signature";
    homepage = "https://github.com/herumi/bls";
    platforms = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
  };
}
