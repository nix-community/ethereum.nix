{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  mockgen,
  nix-update-script,
}: let
  pname = "sedge";
  version = "1.3.1";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "NethermindEth";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-sZILanIIxZ0WQhmN4e7gSysEcjb2pLpy3huUCzYinqU=";
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

    passthru.updateScript = nix-update-script {
      extraArgs = ["--flake"];
    };

    meta = {
      description = "A one-click setup tool for PoS network/chain validators and nodes.";
      homepage = "https://docs.sedge.nethermind.io/";
      mainProgram = "sedge";
      platforms = ["x86_64-linux"];
    };
  }
