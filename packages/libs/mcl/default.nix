{
  fetchFromGitHub,
  gmpxx,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "mcl";
  version = "1.81";

  src = fetchFromGitHub {
    owner = "herumi";
    repo = "mcl";
    rev = "v${version}";
    sha256 = "sha256-aVuBt5T+tNjrK1QahzaCxuimUDQVtoKfK/v0LTT3hy8=";
  };

  buildInputs = [gmpxx];

  installPhase = ''
    make PREFIX=$out/ install
  '';

  meta = {
    description = "A portable and fast pairing-based cryptography library";
    homepage = "https://github.com/herumi/mcl";
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
