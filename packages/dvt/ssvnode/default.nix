{
  bls,
  mcl,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "ssv";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "bloxapp";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-GKUtA3a0M4+WhrVxCpBv0oBi49G0XKIA0YBCYgwpz5U=";
  };

  vendorSha256 = "sha256-u5/TVnpSBOdt3Hq3+JVVyfUwBy1iw51JRdtlB799nXY=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/ssvnode"];

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/bloxapp/ssv";
    platforms = ["x86_64-linux"];
  };
}
