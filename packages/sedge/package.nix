{
  bls,
  buildGoModule,
  fetchFromGitHub,
  lib,
  mcl,
  mockgen,
  nix-update-script,
}:
let
  pname = "sedge";
  version = "1.10.0";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "NethermindEth";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-lZnjWaMyWGfgyqG9+81evzvaGm2DwxlyzUOGl87yesQ=";
  };
  vendorHash = "sha256-UWwhs63U68vuX8iyCE0vwZ0zLa+vukgycaU3Gz+myZI=";
  proxyVendor = true;

  buildInputs = [
    bls
    mcl
  ];
  nativeBuildInputs = [ mockgen ];

  preBuild = ''
    go generate ./...
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/NethermindEth/sedge/internal/utils.Version=v${version}"
  ];
  subPackages = [ "cmd/sedge" ];

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "A one-click setup tool for PoS network/chain validators and nodes.";
    homepage = "https://docs.sedge.nethermind.io/";
    license = lib.licenses.asl20;
    mainProgram = "sedge";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
