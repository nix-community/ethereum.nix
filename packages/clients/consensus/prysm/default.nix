{
  bls,
  blst,
  buildGo120Module,
  fetchFromGitHub,
  libelf,
}:
buildGo120Module rec {
  pname = "prysm";
  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-HnucOREebWXxLB11XJJDAjNFHlukt/HrXeNvQ9BwTds=";
  };

  vendorHash = "sha256-IGeCKaQyyj3nwH62XX37x9bh2s9Qm8NZVkNbH0Yh6so=";

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
