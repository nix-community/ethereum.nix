{
  clang,
  cmake,
  fetchFromGitHub,
  gmpxx,
  lib,
  nix-update-script,
  stdenv,
  system,
}:
stdenv.mkDerivation rec {
  pname = "mcl";
  version = "3.04";

  src = fetchFromGitHub {
    owner = "herumi";
    repo = "mcl";
    rev = "v${version}";
    hash = "sha256-is5P0dhIU1WhAJb7EA085x40Lkw4EA34sgTnCxrcmdE=";
  };

  nativeBuildInputs = [ cmake ] ++ (lib.optionals (system == "aarch64-linux") [ clang ]);
  buildInputs = [ gmpxx ];

  cmakeFlags = lib.optionals (system == "aarch64-linux") [
    "-DCMAKE_CXX_COMPILER=clang++"
    "-DCMAKE_CXX_COMPILER_ID=Clang"
  ];

  installPhase = ''
    make PREFIX=$out/ install
  '';

  passthru = {
    category = "Libraries";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "A portable and fast pairing-based cryptography library";
    homepage = "https://github.com/herumi/mcl";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "aarch64-linux"
    ];
  };
}
