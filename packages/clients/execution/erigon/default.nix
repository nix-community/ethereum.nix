{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "erigon";
  version = "2.40.0";

  src = fetchFromGitHub {
    owner = "ledgerwatch";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Woq9QmRtOMgpdKWUd0JHBTQTmxv7N3A+lCfCPCNRr7U=";
    fetchSubmodules = true;
  };

  vendorSha256 = "sha256-SgJnXN2gceyRLzrHq3hn5Z2EnJGkIKzR4+5HWv6D6+4=";
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
