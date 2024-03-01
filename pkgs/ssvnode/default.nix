{
  bls,
  mcl,
  buildGo120Module,
  fetchFromGitHub,
}:
buildGo120Module rec {
  pname = "ssv";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "bloxapp";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-mEkr35yhwWWZGICRsmIAKe6SoyddP3GmFgJXt1ioNp4=";
  };

  vendorHash = "sha256-AoJowh9HFjnMcM0RC0MeBeZy1c4bT2Nf8kF0CuSt73Q=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/ssvnode"];

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/bloxapp/ssv";
    platforms = ["x86_64-linux"];
    mainProgram = "ssvnode";
  };
}
