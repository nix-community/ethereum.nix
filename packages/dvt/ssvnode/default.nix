{
  bls,
  mcl,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "ssv";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "bloxapp";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-tMk91zKURbqREdeBnz6bc2UqKOBZA1TY6ueJdU0vAFM=";
  };

  vendorSha256 = "sha256-u5/TVnpSBOdt3Hq3+JVVyfUwBy1iw51JRdtlB799nXY=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/ssvnode"];

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/bloxapp/ssv";
    platforms = ["x86_64-linux"];
    mainProgram = "ssvnode";
  };
}
