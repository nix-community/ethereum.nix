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
  version = "7.1.3";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-VAyoJphP/WMsEoF+4CEz5VCxh7U5s753yaW18cPUWUM=";
  };

  vendorHash = "sha256-/XPzjg52JLlU33nYtOgBJ+R6r9j40ev46aPBggOlL7c=";

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
    "-X github.com/prysmaticlabs/prysm/v4/runtime/version.gitTag=v${version}"
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
