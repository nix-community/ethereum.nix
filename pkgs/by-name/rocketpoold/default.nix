{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.18.2";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-iJxuVhH8npmLwvlp9Q3hap3MN5l+708MURhE0x+Pybg=";
  };

  vendorHash = "sha256-fmmeANTesBbC8Nf7NasUUAvzn+w68xm0HjttY4UD2eU=";

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
