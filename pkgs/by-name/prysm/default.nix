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
  version = "7.1.1";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-cOUjg14wYcIZpRQLGGnOkuO1jv2guL+trLuxkYoHuCc=";
  };

  vendorHash = "sha256-aLfMBumqgUjLl34O/N0lWymag+88T3v63WqJm/U+lMQ=";

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
