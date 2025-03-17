{
  cli11,
  cmake,
  fetchFromGitHub,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "evmc";
  version = "10.0.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "evmc";
    rev = "v${version}";
    hash = "sha256-e6V7lNszvR8mmLhPk7pvFMh2LQUl/VHupzVgMfsNlsM=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [cli11];

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

  meta = {
    description = "EVMC – Ethereum Client-VM Connector API";
    homepage = "https://github.com/ethereum/evmc";
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
