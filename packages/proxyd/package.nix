{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "proxyd";
  version = "4.36.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "infra";
    rev = "proxyd/v${version}";
    hash = "sha256-L8Wj39ZHaot7b+VjlgjyBR4IPamoNrQ/aMnRFwlQ1Yk=";
  };

  sourceRoot = "${src.name}/proxyd";

  proxyVendor = true;
  vendorHash = "sha256-59J6qZEvmqgfFba/391skJrXgEz6djqLUoO4cN/rO54=";

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
    changelog = "https://github.com/ethereum-optimism/infra/releases";
    license = licenses.mit;
    mainProgram = "proxyd";
    platforms = platforms.unix;
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
