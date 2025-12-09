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
  version = "7.0.1";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-vv1UF4mlw24aQ0MkrPvu3LRlmWJ1Rr1i452ntbCpr7Y=";
  };

  vendorHash = "sha256-qD65NoPCj8YH0vl4szu3sDDn0y4w3cmcQZFzhHZpqMM=";

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
