{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "proxyd";
  version = "4.27.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "infra";
    rev = "proxyd/v${version}";
    hash = "sha256-9z78Htz0pDPYxjL00b+LF6wgZ/ps+0b8s9grA0eFYWk=";
  };

  sourceRoot = "${src.name}/proxyd";

  proxyVendor = true;
  vendorHash = "sha256-bFzoFArkyB04qEfeamabqgUbLvYvrLanXr3Id0ESUkc=";

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
