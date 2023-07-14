{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "erigon";
  version = "2.48.1";

  src = fetchFromGitHub {
    owner = "ledgerwatch";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ApVsrK1Di6d3WBj/VIUcYJBceFDTeNfsXYPRfbytvZg=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-bsPeEAhvuT5GIpYMoyPyh0BHMDKyKjBiVnYLjtF4Mkc=";
  proxyVendor = true;

  # Build errors in mdbx when format hardening is enabled:
  #   cc1: error: '-Wformat-security' ignored without '-Wformat' [-Werror=format-security]
  hardeningDisable = ["format"];

  subPackages = [
    "cmd/erigon"
    "cmd/evm"
    "cmd/rpcdaemon"
    "cmd/rlpdump"
  ];

  meta = {
    description = "Ethereum node implementation focused on scalability and modularity";
    homepage = "https://github.com/ledgerwatch/erigon/";
    mainProgram = "erigon";
    platforms = ["x86_64-linux"];
  };
}
