{
  bls,
  blst,
  buildGo121Module,
  fetchFromGitHub,
  libelf,
}:
buildGo121Module rec {
  pname = "prysm";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-h1ff0FqFdJMImkCI8UxRwjHqOfZuS56Mo73QJGVtE9Q=";
  };

  vendorHash = "sha256-cR1/OxL2qulK8FLm469X7SwFDCxFfyEVv0vro2Fv48w=";

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
