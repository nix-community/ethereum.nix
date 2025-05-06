{
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  subPackages ? ["cmd/erigon" "cmd/evm" "cmd/rpcdaemon" "cmd/rlpdump"],
}:
buildGoModule rec {
  pname = "erigon";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "erigontech";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-gSgkdg7677OBOkAbsEjxX1QttuIbfve2A3luUZoZ5Ik=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-8eyC3JkRcRlFw8CyTK5w1XySur2jAeFGXkEaY/3Oq0k=";
  proxyVendor = true;

  # Silkworm's .so fails to find libgmp when linking
  tags = ["nosilkworm"];

  # Build errors in mdbx when format hardening is enabled:
  #   cc1: error: '-Wformat-security' ignored without '-Wformat' [-Werror=format-security]
  hardeningDisable = ["format"];

  ldflags = ["-extldflags \"-Wl,--allow-multiple-definition\""];
  inherit subPackages;

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Ethereum node implementation focused on scalability and modularity";
    homepage = "https://github.com/erigontech/erigon/";
    mainProgram = "erigon";
    platforms = ["x86_64-linux"];
  };
}
