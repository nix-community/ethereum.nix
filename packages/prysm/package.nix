{
  bls,
  blst,
  ckzg,
  buildGoModule,
  fetchFromGitHub,
  libelf,
  nix-update-script,
}:
buildGoModule rec {
  pname = "prysm";
  version = "7.1.2";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-q9RTwlOOxJ8X8HcAa6HHaTqxp1w9A+Rlk2aQekzvj1o=";
  };

  vendorHash = "sha256-aLfMBumqgUjLl34O/N0lWymag+88T3v63WqJm/U+lMQ=";

  buildInputs = [
    bls
    blst
    ckzg
    libelf
  ];

  preBuild = ''
    # Set up C-KZG and blst environment variables for Go bindings
    export CGO_CFLAGS="-I${ckzg}/include -I${ckzg}/src -I${blst}/include"
    export CGO_LDFLAGS="-L${ckzg}/lib -lckzg"
  '';

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

  passthru = {
    category = "Consensus Clients";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Go implementation of Ethereum proof of stake";
    homepage = "https://github.com/prysmaticlabs/prysm";
    mainProgram = "beacon-chain";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
