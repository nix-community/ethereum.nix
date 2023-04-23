{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  libelf,
}:
buildGoModule rec {
  pname = "prysm";
  version = "4.0.3";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-pph6e1qit8fInLU1rLcCMSbXjt7ZOuR4E2fKcu0oRCY=";
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
    platforms = ["x86_64-linux"];
  };
}
