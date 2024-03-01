{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mev-boost";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-Z5B+PRYb6eWssgyaXpXoHOVRoMZoSAwun7s6Fh1DrfM=";
  };

  vendorHash = "sha256-yfWDGVfgCfsmzI5oxEmhHXKCUAHe6wWTkaMkBN5kQMw=";

  buildInputs = [blst];

  subPackages = ["cmd/mev-boost"];

  meta = {
    description = "MEV-Boost allows proof-of-stake Ethereum consensus clients to source blocks from a competitive builder marketplace";
    homepage = "https://github.com/flashbots/mev-boost";
    mainProgram = "mev-boost";
    platforms = ["x86_64-linux"];
  };
}
