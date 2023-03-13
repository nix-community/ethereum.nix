{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
}:
buildGoModule rec {
  pname = "charon";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-UCr3ZQp+MQi7xNGwV7mRMJw6RvDPSYtASde/+8Z3u9Q=";
  };

  vendorSha256 = "sha256-t2VsMc+DtNPjWpX1yV6NDzbE50JpD+TqdH9Uu1q5+e0=";

  buildInputs = [bls mcl];

  ldflags = ["-s" "-w"];

  subPackages = ["."];

  meta = {
    description = "Charon (pronounced 'kharon') is a Proof of Stake Ethereum Distributed Validator Client";
    homepage = "https://github.com/ObolNetwork/charon";
    platforms = ["x86_64-linux"];
  };
}
