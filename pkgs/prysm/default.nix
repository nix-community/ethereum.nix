{
  bls,
  blst,
  buildGo121Module,
  fetchFromGitHub,
  libelf,
}:
buildGo121Module rec {
  pname = "prysm";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-a/HBcrVLL6CAzM6/iX3dfsiIAhXyC0RaLoRXKcGGBSM=";
  };

  vendorHash = "sha256-6qcIspi+60IfMiWVFtGhnu8v6llZKv2nMFMbCrPw1NQ=";

  buildInputs = [bls blst libelf];

  subPackages = [
    "cmd/beacon-chain"
    "cmd/client-stats"
    "cmd/prysmctl"
    "cmd/validator"
  ];

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/prysmaticlabs/prysm/v4/runtime/version.gitTag=v${version}"
  ];

  meta = {
    description = "Go implementation of Ethereum proof of stake";
    homepage = "https://github.com/prysmaticlabs/prysm";
    mainProgram = "beacon-chain";
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
