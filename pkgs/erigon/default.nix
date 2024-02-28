{
  buildGoModule,
  fetchFromGitHub,
  subPackages ? ["cmd/erigon" "cmd/evm" "cmd/rpcdaemon" "cmd/rlpdump"],
}:
buildGoModule rec {
  pname = "erigon";
  version = "2.58.1";

  src = fetchFromGitHub {
    owner = "ledgerwatch";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-jeOV86QVRQ6RiXUPesa+RbYgSe/t43xYZ8X9t/d9fMs=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-DOsM0G0idAHUsil4KNkmghq3VZwVE1ub6fAvRnELHn0=";
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
