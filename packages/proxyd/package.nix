{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "proxyd";
  version = "4.27.5";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "infra";
    rev = "proxyd/v${version}";
    hash = "sha256-3iCRG5Bdic66xGF/bI14kLPAet7pI30RllqhhQvjqX0=";
  };

  sourceRoot = "${src.name}/proxyd";

  proxyVendor = true;
  vendorHash = "sha256-z7mdiD0bGCI6UT8uN3RpuRIoZXGdcv9JUp9ssBy/SXQ=";

  subPackages = [ "cmd/proxyd" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.GitVersion=v${version}"
  ];

  doCheck = false;

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "RPC request router and proxy for Optimism";
    homepage = "https://github.com/ethereum-optimism/infra/tree/main/proxyd";
    license = licenses.mit;
    mainProgram = "proxyd";
    platforms = platforms.unix;
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
