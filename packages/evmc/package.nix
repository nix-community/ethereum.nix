{
  cli11,
  cmake,
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "evmc";
  version = "12.1.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "evmc";
    rev = "v${version}";
    hash = "sha256-VbhU5FcAW0PkHcvS6tbEkhNnx1NErTv4yH57g9bAdh4=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ cli11 ];

  cmakeFlags = [
    "-DEVMC_INSTALL=ON"
    "-DEVMC_TESTING=OFF"
    "-DEVMC_TOOLS=OFF"
    "-DHUNTER_ENABLED=OFF"
  ];

  patches = [
    ./001-Disable-vmtester.patch
    ./002-Disable-hunter-package.patch
  ];

  passthru = {
    category = "Libraries";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "EVMC – Ethereum Client-VM Connector API";
    homepage = "https://github.com/ethereum/evmc";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
