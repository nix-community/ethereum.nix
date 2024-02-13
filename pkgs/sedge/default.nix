{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  mockgen,
}: let
  pname = "sedge";
  version = "1.3.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "NethermindEth";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-fwkbJQ56QL6Q5cYd/kUhuyvL+n3Nf35xWszMTRQdJkY=";
    };
    vendorHash = "sha256-HZ/v5bY4BHXYw+8tGirukwFoLTQccDl0c1iPhsla424=";
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

    meta = {
      description = "A one-click setup tool for PoS network/chain validators and nodes.";
      homepage = "https://docs.sedge.nethermind.io/";
      mainProgram = "sedge";
      platforms = ["x86_64-linux"];
    };
  }
