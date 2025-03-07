{
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

  subPackages = ["rocketpool-cli"];

  postInstall = ''
    mv $out/bin/rocketpool-cli $out/bin/rocketpool
  '';

  meta = {
    description = "Rocket Pool CLI";
    homepage = "https://github.com/rocket-pool/smartnode";
    mainProgram = "rocketpool";
    platforms = ["aarch64-linux" "x86_64-linux"];
  };
}
