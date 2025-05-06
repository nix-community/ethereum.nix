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
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-H16YiHZa/flGXRretA+HqJZjPwDe8nFp770eMueM0e0=";
  };

  vendorHash = "sha256-oKT0pmV6Gt57ZeiIcu73QblBJ3uimEsuSTbAbC2W6jc=";

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
