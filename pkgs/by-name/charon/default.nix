{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "charon";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    hash = "sha256-KDJgSj0BdjAMIwz1eK3X10AiUdQTiiTXAKYI7TJX1xU=";
  };

  vendorHash = "sha256-Sz3mqy/xoyCiuV5EJieo89UnbuBFnBQORmAUZpEmAsA=";

  buildInputs = [bls mcl];

  ldflags = ["-s" "-w"];

  subPackages = ["."];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Charon (pronounced 'kharon') is a Proof of Stake Ethereum Distributed Validator Client";
    homepage = "https://github.com/ObolNetwork/charon";
    mainProgram = "charon";
    platforms = ["x86_64-linux"];
  };
}
