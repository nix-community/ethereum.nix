{
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  subPackages ? ["cmd/erigon" "cmd/evm" "cmd/rpcdaemon" "cmd/rlpdump"],
}:
buildGoModule rec {
  pname = "erigon";
  version = "2.58.0";

  src = fetchFromGitHub {
    owner = "ledgerwatch";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-IbH3PdZD4xNlIgGxlnarqnlaQAviKdc6i+e/Fbly2wE=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-p3tTQ+x5cL+dIc1584DELWL1XXkVZqgDw13i0VLQlDM=";
  proxyVendor = true;

  # Silkworm's .so fails to find libgmp when linking
  tags = ["nosilkworm"];

  # Build errors in mdbx when format hardening is enabled:
  #   cc1: error: '-Wformat-security' ignored without '-Wformat' [-Werror=format-security]
  hardeningDisable = ["format"];

  ldflags = ["-extldflags \"-Wl,--allow-multiple-definition\""];
  inherit subPackages;

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = {
    description = "Ethereum node implementation focused on scalability and modularity";
    homepage = "https://github.com/ledgerwatch/erigon/";
    mainProgram = "erigon";
    platforms = ["x86_64-linux"];
  };
}
