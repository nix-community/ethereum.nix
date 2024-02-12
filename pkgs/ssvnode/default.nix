{
  bls,
  mcl,
  buildGo120Module,
  fetchFromGitHub,
}:
buildGo120Module rec {
  pname = "ssv";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "bloxapp";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-POcz5TxeGfqdoYD0YSDD9Rt3UTPW1fayn2w0Rm2LEAk=";
  };

  vendorHash = "sha256-FtY7xK1OvA0Tluo96zSdie2tpRVHiDcJdT0Z7ledDWk=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/ssvnode"];

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/bloxapp/ssv";
    platforms = ["x86_64-linux"];
    mainProgram = "ssvnode";
  };
}
