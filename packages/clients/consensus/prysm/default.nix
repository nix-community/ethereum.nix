{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  libelf,
}:
buildGoModule rec {
  pname = "prysm";
  version = "4.0.4";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-NgFX81co51Iab2PL0TqXI8lUbS8m7f6YEmR8KRUr3xg=";
  };

  vendorHash = "sha256-mnMINLAP929IfIQuI4fQatR+dr1HID1/FdJk7z6U3M8=";

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
