{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
}:
buildGoModule rec {
  pname = "charon";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    hash = "sha256-v9nqm1LCehuAZ0S3BDo4yCfRsfxReu37s082nm4KbMA=";
  };

  vendorHash = "sha256-SOsnjPvIJ2dqrWJD7dW/QZBkQZW2vdzTOALFCLGb2Ys=";

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
