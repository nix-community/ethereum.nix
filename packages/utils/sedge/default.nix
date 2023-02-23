{
  bls,
  buildGoModule,
  fetchFromGitHub,
  lib,
  mcl,
}:
buildGoModule rec {
  pname = "sedge";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "NethermindEth";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-U48ZM/J/Wj8chQvVB1DuqS3zl/qFMxDzlWS7Y3+U43Y=";
  };

  vendorSha256 = "sha256-zT6KX01NZbhuf8RqBuNqE3w4KDseBZBaXD1dqbyyC3U=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/sedge"];

  meta = with lib; {
    homepage = "https://docs.sedge.nethermind.io/";
    description = "A one-click setup tool for PoS network/chain validators and nodes.";
    platforms = ["x86_64-linux"];
  };
}
