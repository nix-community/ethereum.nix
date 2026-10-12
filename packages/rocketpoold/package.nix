{
  bls_1_86,
  blst,
  buildGo127Module,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGo127Module rec {
  pname = "rocketpool";
  version = "1.24.4";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-qP4Dd2q3FUqo+MHdSHe8T8R64U3rmRX4SzQLgNjAubA=";
  };

  vendorHash = "sha256-k4P5wadzM4n27LInxvosRJmfvdMcNsF0e0ovH4wfMbA=";

  proxyVendor = true;

  buildInputs = [
    bls_1_86
    blst
  ];

  subPackages = [ "rocketpool" ];

  env.CGO_CFLAGS = "-O -D__BLST_PORTABLE__ -I${blst}/include";
  env.CGO_ENABLED = 1;
  postInstall = ''
    mv $out/bin/rocketpool $out/bin/rocketpoold
  '';

  passthru = {
    category = "Staking";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Rocket Pool Daemon";
    homepage = "https://github.com/rocket-pool/smartnode";
    license = lib.licenses.gpl3Only;
    mainProgram = "rocketpoold";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
