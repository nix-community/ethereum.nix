{
  bls,
  blst,
  buildGo123Module,
  fetchFromGitHub,
  nix-update-script,
}:
# 1.23 is force due to this issue:
# https://github.com/NordSecurity/uniffi-bindgen-go/issues/66
# this can likely be removed in the next upstream version
buildGo123Module rec {
  pname = "rocketpool";
  version = "1.15.6";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-vXk7WgN77SWDVzOs5QBJsPO8O4AJiS+VbUl1xNmZOP0=";
  };

  vendorHash = "sha256-tsrhti14Lj/yc8IZbiWi5wqDxJh4/m3FR2cpu1bh/hg=";

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
