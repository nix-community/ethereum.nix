{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  libelf,
}:
buildGoModule rec {
  pname = "prysm";
  version = "4.0.8";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-9aztKZoZPZzyeQxGJXGslbzjhMdS2qdUJuze2y3rUN4=";
  };

  vendorHash = "sha256-lYDeHyWoCV4fshjK8wlRVg+rb8Ap0fxeFLl2og3W7Bo=";

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
