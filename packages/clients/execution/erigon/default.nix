{
  buildGoModule,
  fetchFromGitHub,
  subPackages ? ["cmd/erigon" "cmd/evm" "cmd/rpcdaemon" "cmd/rlpdump"],
}:
buildGoModule rec {
  pname = "erigon";
  version = "2.50.1";

  src = fetchFromGitHub {
    owner = "ledgerwatch";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-j5MHcqlLSq/EpipJmIfqhGMosw6SpmxYBEYPVP7gyDM=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-4s5dXTfYlgzYQ2h30F6kxEF626iKYFRoZlNXeFDbn8s=";
  proxyVendor = true;

  # Build errors in mdbx when format hardening is enabled:
  #   cc1: error: '-Wformat-security' ignored without '-Wformat' [-Werror=format-security]
  hardeningDisable = ["format"];

  ldflags = ["-extldflags \"-Wl,--allow-multiple-definition\""];
  inherit subPackages;

  meta = {
    description = "Ethereum node implementation focused on scalability and modularity";
    homepage = "https://github.com/ledgerwatch/erigon/";
    mainProgram = "erigon";
    platforms = ["x86_64-linux"];
  };
}
