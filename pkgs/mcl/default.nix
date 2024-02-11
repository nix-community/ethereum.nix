{
  fetchFromGitHub,
  gmpxx,
  stdenv,
  clang,
  cmake,
  system,
  lib,
}:
stdenv.mkDerivation rec {
  pname = "mcl";
  version = "1.81";

  src = fetchFromGitHub {
    owner = "herumi";
    repo = "mcl";
    rev = "v${version}";
    hash = "sha256-aVuBt5T+tNjrK1QahzaCxuimUDQVtoKfK/v0LTT3hy8=";
  };

  nativeBuildInputs = [cmake] ++ (lib.optionals (system == "aarch64-linux") [clang]);
  buildInputs = [gmpxx];

  cmakeFlags = lib.optionals (system == "aarch64-linux") [
    "-DCMAKE_CXX_COMPILER=clang++"
    "-DCMAKE_CXX_COMPILER_ID=Clang"
  ];

  installPhase = ''
    make PREFIX=$out/ install
  '';

  meta = {
    description = "A portable and fast pairing-based cryptography library";
    homepage = "https://github.com/herumi/mcl";
    platforms = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
  };
}
