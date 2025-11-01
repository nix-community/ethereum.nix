{
  blst,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "mev-boost";
  version = "1.10.0";
  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-YPvSlR03whY0s2p/GX2yHDSPd8+ElU/0aqziJFhlCZw=";
  };

  vendorHash = "sha256-FpkQp/PgmZ9+swQYI984j87ODbT0kpanBkHfJK86FWA=";

  buildInputs = [blst];

  subPackages = ["cmd/mev-boost"];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "MEV-Boost allows proof-of-stake Ethereum consensus clients to source blocks from a competitive builder marketplace";
    homepage = "https://github.com/flashbots/mev-boost";
    mainProgram = "mev-boost";
    platforms = ["x86_64-linux"];
  };
}
