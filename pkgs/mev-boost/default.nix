{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mev-boost";
  version = "1.9-rc2";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-TRcqtX3V7OagWlpiT8tK7P4Up27JE7EHtacFJbsHau4=";
  };

  vendorHash = "sha256-YUm9Kz+pB8fPSh3eOdrfk2OMc7fNj1gXD7IeYiW2cuQ=";

  buildInputs = [blst];

  subPackages = ["cmd/mev-boost"];

  meta = {
    description = "MEV-Boost allows proof-of-stake Ethereum consensus clients to source blocks from a competitive builder marketplace";
    homepage = "https://github.com/flashbots/mev-boost";
    mainProgram = "mev-boost";
    platforms = ["x86_64-linux"];
  };
}
