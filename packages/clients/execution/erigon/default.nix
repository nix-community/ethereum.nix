{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "erigon";
  version = "2.40.1";

  src = fetchFromGitHub {
    owner = "ledgerwatch";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-iuJ/iajZiqKBP4hgrwt8KKkWEdYa+idpai/aWpCOjQw=";
    fetchSubmodules = true;
  };

  vendorSha256 = "sha256-0xHu7uvk7kRxyLXGvrT9U8vgfZPrs7Rmg2lFH49YOSI=";
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
