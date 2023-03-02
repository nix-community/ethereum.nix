{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
}:
buildGoModule rec {
  pname = "charon";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-j5Y+9RgJqWuTuVPIHSdTcAYVVb7G+06taBDVLbVqNaE=";
  };

  vendorSha256 = "sha256-tz3fDnOJAEUbSeeRoSZ/2ha77bFYJKIwVx29vxACqYo=";

  buildInputs = [bls mcl];

  ldflags = ["-s" "-w"];

  subPackages = ["."];

  meta = {
    description = "Charon (pronounced 'kharon') is a Proof of Stake Ethereum Distributed Validator Client";
    homepage = "https://github.com/ObolNetwork/charon";
    platforms = ["x86_64-linux"];
  };
}
