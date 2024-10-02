{
  buildGoModule,
  fetchFromGitHub,
  subPackages ? ["cmd/erigon" "cmd/evm" "cmd/rpcdaemon" "cmd/rlpdump"],
}:
buildGoModule rec {
  pname = "erigon";
  version = "2.60.8";

  src = fetchFromGitHub {
    owner = "ledgerwatch";
    repo = pname;
    rev = "${version}";
    hash = "sha256-cHEJbRP/v1GOmpfjrYjso2d+SVcXG+TEiIZoX+sSdYQ=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-J535F9xXtxuCHvshJOJ63fOGpa5ZhReaOu9+jAKXDfo=";
  proxyVendor = true;

  # Silkworm's .so fails to find libgmp when linking
  tags = ["nosilkworm"];

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
