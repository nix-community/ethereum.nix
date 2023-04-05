{
  bls,
  mcl,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "ssv";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "bloxapp";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-Iwi9+tYg0tL8LdI7vLbdFjNEJmE7DWZeE0RG29X80F8=";
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
