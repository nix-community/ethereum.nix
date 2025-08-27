{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  mockgen,
  nix-update-script,
}: let
  pname = "sedge";
  version = "1.9.1";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "NethermindEth";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-gjdRa0cjeRimMg2EpI81DagbauTq2eotlpoVx7nqVns=";
    };
    vendorHash = "sha256-UWwhs63U68vuX8iyCE0vwZ0zLa+vukgycaU3Gz+myZI=";
    proxyVendor = true;

    buildInputs = [bls mcl];
    nativeBuildInputs = [mockgen];

    preBuild = ''
      go generate ./...
    '';

    ldflags = [
      "-s"
      "-w"
      "-X github.com/NethermindEth/sedge/internal/utils.Version=v${version}"
    ];
    subPackages = ["cmd/sedge"];

    passthru.updateScript = nix-update-script {};

    meta = {
      description = "A one-click setup tool for PoS network/chain validators and nodes.";
      homepage = "https://docs.sedge.nethermind.io/";
      mainProgram = "sedge";
      platforms = ["x86_64-linux"];
    };
  }
