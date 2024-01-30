{
  cmake,
  fetchFromGitHub,
  lib,
  stdenv,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "libtorsion";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "bcoin-org";
    repo = "libtorsion";
    rev = "52cee7b5ef4d025e311aeb83b2af07eb98ea5470";
    hash = "sha256-ys8Gs4Tb+g3mSaiZEdO55y6aiP0FSZBEnXApaFCy3FE=";
  };

  postPatch = ''
    substituteInPlace libtorsion-cmake.pc.in \
      --replace '$'{exec_prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@ \
      --replace '$'{prefix}/@CMAKE_INSTALL_INCLUDEDIR@ @CMAKE_INSTALL_FULL_INCLUDEDIR@
  '';

  nativeBuildInputs = [pkg-config cmake];

  meta = with lib; {
    homepage = "https://github.com/bcoin-org/libtorsion";
    description = "C Crypto Library";
    license = licenses.mit;
    platforms = ["x86_64-linux"];
  };
}
