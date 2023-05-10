{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
}:
buildGoModule rec {
  pname = "charon";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    hash = "sha256-W7Sy/dsaYpZOpsEaGuHeTMi336RmKp0756TuUisM0IA=";
  };

  vendorSha256 = "sha256-MVEMI8BJnDogZVC7Kc2wVa2znqybqby2Zb9kuW+Lc44=";

  buildInputs = [bls mcl];

  ldflags = ["-s" "-w"];

  subPackages = ["."];

  meta = {
    description = "Charon (pronounced 'kharon') is a Proof of Stake Ethereum Distributed Validator Client";
    homepage = "https://github.com/ObolNetwork/charon";
    mainProgram = "charon";
    platforms = ["x86_64-linux"];
  };
}
