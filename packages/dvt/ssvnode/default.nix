{
  bls,
  mcl,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "ssv";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "bloxapp";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-Mzdgx/Z0B0K//25adtj04By/DXku1ULu9SPoKI6PZ8c=";
  };

  vendorSha256 = "sha256-KqR7xvXtOpGS8chYaNuJm1mGc7azFwVdH4gXg22nbsg=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/ssvnode"];

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/bloxapp/ssv";
    platforms = ["x86_64-linux"];
  };
}
