{
  bls_1_86,
  blst,
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.20.4";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-2KuwgwPS57tXq0gkv/Pu8h4S5b6AH+pfwK0ph/ocHac=";
  };

  vendorHash = "sha256-0Fm3zU2qPEUnqs4WNTKxtOegUjrxXYkRGI969iTw3qw=";

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
