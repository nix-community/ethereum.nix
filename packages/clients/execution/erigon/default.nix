{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "erigon";
  version = "2.41.0";

  src = fetchFromGitHub {
    owner = "ledgerwatch";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-6qr69Lu47oICT0ZbPw1TknD86ltx/Cl4u7xEbUqdgjY=";
    fetchSubmodules = true;
  };

  vendorSha256 = "sha256-9+7qBzQHOHkfLshU+ojf6FvKG5qjPKr07+iMcwoIpXQ=";
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

  meta = with lib; {
    homepage = "https://github.com/ledgerwatch/erigon/";
    description = "Ethereum node implementation focused on scalability and modularity";
    platforms = ["x86_64-linux"];
  };
}
