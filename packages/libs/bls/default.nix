{
  cmake,
  fetchFromGitHub,
  gmp,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "bls";
  version = "1.29.1";

  src = fetchFromGitHub {
    owner = "herumi";
    repo = "bls";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-6vik2E2wIivpf+hIz3ub+COApcJbyu+W6jNzZI6HWq8=";
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
