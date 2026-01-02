{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.18.7";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-QsK5p7X+1i6/aeIXPVH13LSRpGzIUcHgpDePp6bqDkU=";
  };

  vendorHash = "sha256-8a2CNruHB04FY4cGUqCJYglzanKwYdcOFMnl9yTQDHI=";

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
