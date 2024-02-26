{
  bls,
  blst,
  buildGo121Module,
  fetchFromGitHub,
  libelf,
}:
buildGo121Module rec {
  pname = "prysm";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-QSfTDjdsd6XSYDjhDL+p/0cYlXysVHqlzVMF2KMyd/Y=";
  };

  vendorHash = "sha256-5ToSVJ7ToDhRq3AT6I6G8FE8GqZRPCMyTogTQG4HDBY=";

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
