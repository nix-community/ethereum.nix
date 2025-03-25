{
  bls,
  blst,
  buildGo124Module,
  fetchFromGitHub,
  libelf,
  nix-update-script,
}:
buildGo124Module rec {
  pname = "prysm";
  version = "5.3.2";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Nptf4ORSSx6m2wlPhUwzihMX+yWyGGP4l0VNsaOQFJU=";
  };

  vendorHash = "sha256-sS6fIVF707J2fgtAwI8QAVFDnZqIStemqTXrNL2RKiI=";

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
