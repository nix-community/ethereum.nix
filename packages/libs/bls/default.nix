{
  cmake,
  fetchFromGitHub,
  gmp,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "bls";
  version = "1.35";

  src = fetchFromGitHub {
    owner = "herumi";
    repo = "bls";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-fHwNiZ0B5ow9GBWjO5c+rpK/jlziaMF5Bh+HQayIBUI=";
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
