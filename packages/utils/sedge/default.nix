{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  mockgen,
}: let
  pname = "sedge";
  version = "1.1.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "NethermindEth";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-rIBHRiVZT3XXZB8zuFOoX02/g/DhBvIwa+sdis1XSYs=";
    };
    vendorHash = "sha256-aLH+Ob9jRrE6z5FqJUZpdUMtsHYtw+QiTJrV3LsW0CU=";
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
      homepage = "https://docs.sedge.nethermind.io/";
      description = "A one-click setup tool for PoS network/chain validators and nodes.";
      platforms = ["x86_64-linux"];
    };
  }
