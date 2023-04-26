{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
}: let
  pname = "sedge";
  version = "1.1.0";
in
  buildGoModule rec {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "NethermindEth";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-rIBHRiVZT3XXZB8zuFOoX02/g/DhBvIwa+sdis1XSYs=";
    };

    vendorHash = "sha256-MM8Uo4SMpRanhYRB0+Swjccza4sCCpp/YByXx+ptSB8=";

    #doCheck = false;

    buildInputs = [bls mcl];

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
