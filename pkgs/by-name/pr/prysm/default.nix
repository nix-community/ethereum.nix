{
  bls,
  blst,
  buildGo123Module,
  fetchFromGitHub,
  libelf,
  nix-update-script,
}:
buildGo123Module rec {
  pname = "prysm";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-bTA7KOfhdsVIQk6d9pnBAYmmuzj3KQnvMO/OrEpx5uA=";
  };

  vendorHash = "sha256-1PAeAI6yaXSE881Bsp2hhPSctePc5CwWYkk8QVounAA=";

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

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Go implementation of Ethereum proof of stake";
    homepage = "https://github.com/prysmaticlabs/prysm";
    mainProgram = "beacon-chain";
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
