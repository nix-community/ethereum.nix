{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mev-boost";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-4Vxs1Jo7rkw9l0pXfi+J7YmzQawt7tc19I1MdHQgjBA=";
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
