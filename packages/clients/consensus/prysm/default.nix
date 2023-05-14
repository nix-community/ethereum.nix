{
  bls,
  blst,
  buildGo119Module,
  fetchFromGitHub,
  libelf,
}:
buildGo119Module rec {
  pname = "prysm";
  version = "4.0.3-hotfix";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-XYEmhXe8xC0LsyTh9horH7XCBr/yL23guUHlltShkts=";
  };

  vendorHash = "sha256-JswnnPppZqzByrO+mPZSbbptMnIGWoDXVh3ucCtfjjc=";

  buildInputs = [bls blst libelf];

  subPackages = [
    "cmd/beacon-chain"
    "cmd/client-stats"
    "cmd/prysmctl"
    "cmd/validator"
  ];

  doCheck = false;

  meta = {
    description = "Go implementation of Ethereum proof of stake";
    homepage = "https://github.com/prysmaticlabs/prysm";
    mainProgram = "beacon-chain";
    platforms = ["x86_64-linux"];
  };
}
