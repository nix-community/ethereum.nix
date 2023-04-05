{
  bls,
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "eth2-testnet-genesis";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "protolambda";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-vhpC1ewBMDCgzK0aIiyzNofUSmY39xyJ1BJkJ3ZJAqc=";
  };

  vendorSha256 = "sha256-iXJDZtm68Qk1Za8+Bsk140hyl/GeyXlj47PBEZw1tro=";

  buildInputs = [bls];

  subPackages = ["."];

  ldflags = ["-s" "-w"];

  meta = with lib; {
    homepage = "https://github.com/protolambda/eth2-testnet-genesis";
    description = "Create a genesis state for an Eth2 testnet";
    platforms = ["x86_64-linux"];
  };
}
