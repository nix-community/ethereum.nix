{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "proxyd";
  version = "4.31.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "infra";
    rev = "proxyd/v${version}";
    hash = "sha256-LNsVlpkidXWXr+PBC2ZqDRFchK5opSMds+mnoAoZGos=";
  };

  sourceRoot = "${src.name}/proxyd";

  proxyVendor = true;
  vendorHash = "sha256-9i51bWL8Qqo4YjAkkgpGxPEG/mfDRCxCndt6vVQB560=";

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
