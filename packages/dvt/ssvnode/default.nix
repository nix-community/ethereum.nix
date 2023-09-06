{
  bls,
  mcl,
  buildGo119Module,
  fetchFromGitHub,
}:
buildGo119Module rec {
  pname = "ssv";
  version = "1.0.0-rc.1";

  src = fetchFromGitHub {
    owner = "bloxapp";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-l8wr/+DxNoR3/dGD5UzuOTe2C/ginvsbB7/v9mhqdz4=";
  };

  vendorHash = "sha256-O+T+5AnU+OCXDiQaS+au6olm6ULdFK8nG6HiHg1ORbk=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/ssvnode"];

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/bloxapp/ssv";
    platforms = ["x86_64-linux"];
    mainProgram = "ssvnode";
  };
}
