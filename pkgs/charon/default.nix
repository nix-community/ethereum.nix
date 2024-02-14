{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "charon";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    hash = "sha256-uwDHniPtfYqu0j025LfZt1LLnIGZgoRGJoNmd5TFL4I=";
  };

  vendorHash = "sha256-tsFQu4grArXSWNcxtpHbcac+1vh7DaTRPvgFDersbdc=";

  buildInputs = [bls mcl];

  ldflags = ["-s" "-w"];

  subPackages = ["."];

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = {
    description = "Charon (pronounced 'kharon') is a Proof of Stake Ethereum Distributed Validator Client";
    homepage = "https://github.com/ObolNetwork/charon";
    mainProgram = "charon";
    platforms = ["x86_64-linux"];
  };
}
