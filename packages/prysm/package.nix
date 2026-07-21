{
  bls_1_86,
  blst,
  buildGoModule,
  ckzg,
  fetchFromGitHub,
  lib,
  libelf,
  nix-update-script,
}:
buildGoModule rec {
  pname = "prysm";
  version = "7.1.7";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-077TK2P8ZehUGh1B5CPh+1QiHG4h90YSg+ar3yCTa0U=";
  };

  # The go.mod pins a newer Go patch release (1.26.4) than the Go version
  # currently available in nixpkgs (1.26.3). Relax the directive so that both
  # the goModules (vendor) and main derivations build with the available
  # toolchain (GOTOOLCHAIN=local).
  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "go 1.26.4" "go 1.26.3"
  '';

  vendorHash = "sha256-h17nHNCL9u67THdGzWvzVz+jI3+11MFr8TmER7py6sg=";

  buildInputs = [
    bls_1_86
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
    "-X github.com/OffchainLabs/prysm/v7/runtime/version.gitTag=v${version}"
  ];

  passthru = {
    category = "Consensus Clients";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Go implementation of Ethereum proof of stake";
    homepage = "https://github.com/prysmaticlabs/prysm";
    license = lib.licenses.gpl3Only;
    mainProgram = "beacon-chain";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
