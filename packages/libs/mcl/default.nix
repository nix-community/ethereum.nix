{
  fetchFromGitHub,
  gmpxx,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "mcl";
  version = "1.71.1";

  src = fetchFromGitHub {
    owner = "herumi";
    repo = "mcl";
    rev = "v${version}";
    sha256 = "sha256-wqAAQ9h6HPJjoIx7oZKyY9w04zwzC1PUEvfrWhCakzc=";
  };

  buildInputs = [gmpxx];

  installPhase = ''
    make PREFIX=$out/ install
  '';

  meta = {
    description = "A portable and fast pairing-based cryptography library";
    homepage = "https://github.com/herumi/mcl";
  };
}
