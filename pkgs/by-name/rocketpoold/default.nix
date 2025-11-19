{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.18.5";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-wn7tNOwI0u4K33Kw6X+0qrbFvgCpd5cyVjRJkT8DZ9U=";
  };

  vendorHash = "sha256-ysMP53854FGGjdX2SkjH8Ml/FDWHb0JjYyo0D4QGHWA=";

  buildInputs = [bls blst];

  subPackages = ["rocketpool"];

  env.CGO_CFLAGS = "-O -D__BLST_PORTABLE__";
  env.CGO_ENABLED = 1;
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
