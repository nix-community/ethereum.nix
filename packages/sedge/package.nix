{
  bls_1_86,
  buildGoModule,
  fetchFromGitHub,
  lib,
  mcl,
  mockgen,
  nix-update-script,
}:
let
  pname = "sedge";
  version = "1.11.1";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "NethermindEth";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-wciYY918Y8EcbwEYvMGiWRpYrTPgg6Pfv3d73HWJqkM=";
  };
  vendorHash = "sha256-UWwhs63U68vuX8iyCE0vwZ0zLa+vukgycaU3Gz+myZI=";
  proxyVendor = true;

  buildInputs = [
    bls_1_86
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
