{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  libelf,
}:
buildGoModule rec {
  pname = "prysm";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-7NEMnFDX9xlAcb4DvYXXFE2rK+6OaVT+/QP95XjXJZY=";
  };

  vendorSha256 = "sha256-jAMYC9RittkWQBbknJoUuRNMW230C5nf21N3phNea2s=";

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
