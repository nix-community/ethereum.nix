{
  bls,
  blst,
  buildGo121Module,
  fetchFromGitHub,
  libelf,
}:
buildGo121Module rec {
  pname = "prysm";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-GYZ8EOX+jKy+1wfSC13zFfaWN8VLFfoI9+McRBx48a4=";
  };

  vendorHash = "sha256-2bXpvYUSrd6p3HBRRu/a7DOJlokRd/poPF/VhftwWWA=";

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
