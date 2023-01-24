{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "erigon";
  version = "2.36.1";

  src = fetchFromGitHub {
    owner = "ledgerwatch";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-9TRdXi3axnCLDWxKinkxXKUpGOa6Z9chMp+M1Eenyos=";
    fetchSubmodules = true;
  };

  vendorSha256 = "sha256-GGa40W5XzoahQt/+/pbL+Ew1MDsbtcsOhRF5xQAx/es=";
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
  };
}
