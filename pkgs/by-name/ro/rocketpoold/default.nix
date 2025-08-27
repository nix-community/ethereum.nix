{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.17.2";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-sVVZlzjl1LPKm8L99E716IrfCOqbyFGO2gfy0VXZuic=";
  };

  vendorHash = "sha256-z0wNoMupLJUjJrYFTSpKJSnRoA/yhou0gpaRPPk7szg=";

  buildInputs = [bls blst];

  subPackages = ["rocketpool"];

  CGO_CFLAGS = "-O -D__BLST_PORTABLE__";
  CGO_ENABLED = 1;
  postInstall = ''
    mv $out/bin/rocketpool $out/bin/rocketpoold
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Rocket Pool Daemon";
    homepage = "https://github.com/rocket-pool/smartnode";
    mainProgram = "rocketpoold";
    platforms = ["aarch64-linux" "x86_64-linux"];
  };
}
