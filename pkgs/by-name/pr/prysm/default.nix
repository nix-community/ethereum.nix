{
  bls,
  blst,
  ckzg,
  buildGo124Module,
  fetchFromGitHub,
  libelf,
  nix-update-script,
}:
buildGo124Module rec {
  pname = "prysm";
  version = "6.0.4";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Z11ty5XwLG7G4t1/yJTdZMGpM6xJsYPxfa0xZ2mk+I0=";
  };

  vendorHash = "sha256-WiS4hTFZeJ3gZDumYndkZ8H7B8JP3qzuJQmVqNsIuoo=";

  buildInputs = [bls blst ckzg libelf];

  preBuild = ''
    # Set up C-KZG environment variables for Go bindings
    export CGO_CFLAGS="-I${ckzg}/include -I${ckzg}/src"
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

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Go implementation of Ethereum proof of stake";
    homepage = "https://github.com/prysmaticlabs/prysm";
    mainProgram = "beacon-chain";
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
