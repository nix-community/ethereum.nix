{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "proxyd";
  version = "4.32.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "infra";
    rev = "proxyd/v${version}";
    hash = "sha256-zYWvRchaok4+UPVkglemrzQvBrEPl0/p0deprol3moQ=";
  };

  sourceRoot = "${src.name}/proxyd";

  proxyVendor = true;
  vendorHash = "sha256-ZNbnW9VX0eNhxk4mgn7bYu7D/OVFpxWaUUiE5TkFKcc=";

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
