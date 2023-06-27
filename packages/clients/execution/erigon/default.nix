{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "erigon";
  version = "2.47.0";

  src = fetchFromGitHub {
    owner = "ledgerwatch";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-LmubFpewCEPcLzezEWye8y4Vjv68coxoCtrffxJsodY=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-zgBStaULqbdZmBDi/3AjGx35mh45M3uFkDd5z/vQeMQ=";
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
