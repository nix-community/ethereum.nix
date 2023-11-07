{
  buildGoModule,
  fetchFromGitHub,
  subPackages ? ["cmd/erigon" "cmd/evm" "cmd/rpcdaemon" "cmd/rlpdump"],
}:
buildGoModule rec {
  pname = "erigon";
  version = "2.53.4";

  src = fetchFromGitHub {
    owner = "ledgerwatch";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-kvLaRjJ/VWiRCjnSEmPfE6VsqovV7KrvT9QBgd6wP2E=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-415ALovZo6NjZD/yDw3ckYz2NCuNMYwV34Up7bTBdOQ=";
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
