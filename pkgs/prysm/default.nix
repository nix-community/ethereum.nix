{
  bls,
  blst,
  buildGo121Module,
  fetchFromGitHub,
  libelf,
  nix-update-script,
}:
buildGo121Module rec {
  pname = "prysm";
  version = "4.2.1";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Zwlq6F9CI81M8f8ne/c/Pbe8B3jQFywWwzzNBL30KBk=";
  };

  vendorHash = "sha256-FiZnk92g7ycrLVv9gaWXKiQWXZU/Bnp5Vd8Ivp5ZfbY=";

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

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = {
    description = "Go implementation of Ethereum proof of stake";
    homepage = "https://github.com/prysmaticlabs/prysm";
    mainProgram = "beacon-chain";
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
