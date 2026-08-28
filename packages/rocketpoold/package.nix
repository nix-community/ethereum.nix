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
  version = "1.22.1";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-hVca3FeuMdyz1V+2zLIfRB/aPsdaGPJ9RyO+1HbBTPU=";
  };

  vendorHash = "sha256-Iilyztrl747zuG69LHXO5YLvrrl46WMOWxqOxIlpBtk=";

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
