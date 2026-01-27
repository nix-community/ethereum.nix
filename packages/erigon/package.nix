{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  subPackages ? [
    "cmd/erigon"
    "cmd/evm"
    "cmd/rpcdaemon"
    "cmd/rlpdump"
  ],
}:
buildGoModule rec {
  pname = "erigon";
  version = "3.3.3";

  src = fetchFromGitHub {
    owner = "erigontech";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-yE5i1ya9U7FOdAzazpAZvdbnJ8eMR3Ft4b6eAVAW8cI=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-i/ri6HDaF8Mz7UgO14TPR1GBAxnmYuvWDP/B0L5gRd8=";
  proxyVendor = true;

  # Silkworm's .so fails to find libgmp when linking
  tags = [ "nosilkworm" ];

  # Build errors in mdbx when format hardening is enabled:
  #   cc1: error: '-Wformat-security' ignored without '-Wformat' [-Werror=format-security]
  hardeningDisable = [ "format" ];

  # Fix error: 'Caught SIGILL in blst_cgo_init'
  # https://github.com/bnb-chain/bsc/issues/1521
  CGO_CFLAGS = "-O -D__BLST_PORTABLE__";
  CGO_CFLAGS_ALLOW = "-O -D__BLST_PORTABLE__";

  ldflags = [ "-extldflags \"-Wl,--allow-multiple-definition\"" ];
  inherit subPackages;

  passthru = {
    category = "Execution Clients";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Ethereum node implementation focused on scalability and modularity";
    homepage = "https://github.com/erigontech/erigon/";
    license = lib.licenses.lgpl3Only;
    mainProgram = "erigon";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
