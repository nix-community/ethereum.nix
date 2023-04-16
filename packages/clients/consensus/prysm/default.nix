{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  libelf,
}:
buildGoModule rec {
  pname = "prysm";
  version = "4.0.2";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-WsI+Z4/5/MDrWCAd5KsDBdxEApNYG1IJZwT24Jh5mcE=";
  };

  vendorSha256 = "sha256-aRcNFwE17+js8W8tazBQKTnMcanhhgeJHRH0mMFpr40=";

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
