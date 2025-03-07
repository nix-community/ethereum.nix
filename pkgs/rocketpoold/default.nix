{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.15.3";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-DX1e44m22em1wO1rSsUYOHfbBiTgq8bBTjPpdNsxrDg=";
  };

  vendorHash = "sha256-tsrhti14Lj/yc8IZbiWi5wqDxJh4/m3FR2cpu1bh/hg=";

  buildInputs = [bls blst];

  subPackages = ["rocketpool"];

  CGO_CFLAGS = "-O -D__BLST_PORTABLE__";
  CGO_ENABLED = 1;
  postInstall = ''
    mv $out/bin/rocketpool $out/bin/rocketpoold
  '';

  meta = {
    description = "Rocket Pool Daemon";
    homepage = "https://github.com/rocket-pool/smartnode";
    mainProgram = "rocketpoold";
    platforms = ["aarch64-linux" "x86_64-linux"];
  };
}
