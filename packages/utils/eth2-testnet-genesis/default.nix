{
  bls,
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "eth2-testnet-genesis";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "protolambda";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-/RhMXKMRSEU/MUkpo8RB7d6wRJLFY0ON0G98v9X93Jg=";
  };

  vendorSha256 = "sha256-4Py3TQmylvSmK5+6ios6LCtwg+2IUJ34LXQ0xMfls0w=";

  buildInputs = [bls];

  subPackages = ["."];

  ldflags = ["-s" "-w"];

  meta = with lib; {
    homepage = "https://github.com/protolambda/eth2-testnet-genesis";
    description = "Create a genesis state for an Eth2 testnet";
    platforms = ["x86_64-linux"];
  };
}
