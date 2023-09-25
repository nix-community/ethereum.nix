{
  cmake,
  fetchFromGitHub,
  gmp,
  stdenv,
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

  nativeBuildInputs = [cmake];
  buildInputs = [gmp];

  # ETH2.0 spec
  CFLAGS = [''-DBLS_ETH''];

  meta = {
    description = "BLS threshold signature";
    homepage = "https://github.com/herumi/bls";
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
