{
  bls_1_86,
  blst,
  buildGoModule,
  ckzg,
  fetchFromGitHub,
  lib,
  libelf,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "prysm";
  version = "7.3.2";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-E4H6PD5WZXyNxGIVz24agP2VqzwF4B7Y6YQ3t+xl3dg=";
  };

  vendorHash = "sha256-EJDXoEqgqhwTvg9aGAQvI6sdmA9JRhYKR10YfldqokM=";

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

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Consensus Clients";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Go implementation of Ethereum proof of stake";
    homepage = "https://github.com/prysmaticlabs/prysm";
    changelog = "https://github.com/prysmaticlabs/prysm/releases";
    license = lib.licenses.gpl3Only;
    mainProgram = "beacon-chain";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
