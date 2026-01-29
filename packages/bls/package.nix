{
  clang,
  cmake,
  fetchFromGitHub,
  gmp,
  lib,
  nix-update-script,
  stdenv,
}:
let
  inherit (stdenv.hostPlatform) system;
in
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

  nativeBuildInputs = [ cmake ] ++ (lib.optionals (system == "aarch64-linux") [ clang ]);
  cmakeFlags = lib.optionals (system == "aarch64-linux") [
    "-DCMAKE_CXX_COMPILER=clang++"
    "-DCMAKE_CXX_COMPILER_ID=Clang"
  ];

  buildInputs = [ gmp ];

  # ETH2.0 spec
  CFLAGS = [ "-DBLS_ETH" ];

  passthru = {
    updateScript = nix-update-script { };
    category = "Libraries";
  };

  meta = {
    description = "BLS threshold signature";
    homepage = "https://github.com/herumi/bls";
    license = lib.licenses.bsd3;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
