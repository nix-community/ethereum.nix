{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mev-boost";
  version = "1.6.4844-dev2";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-Fh6jmB1Babnw+obsVyDgCq93WejQg878ZS14X+ievvU=";
  };

  vendorHash = "sha256-HyYC6UU9/AzUa4FaIRaQzmdJkIJqJmYsam73v+40jsM=";

  buildInputs = [blst];

  subPackages = ["cmd/mev-boost"];

  meta = {
    description = "MEV-Boost allows proof-of-stake Ethereum consensus clients to source blocks from a competitive builder marketplace";
    homepage = "https://github.com/flashbots/mev-boost";
    mainProgram = "mev-boost";
    platforms = ["x86_64-linux"];
  };
}
