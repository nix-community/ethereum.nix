{
  bls,
  mcl,
  buildGo120Module,
  fetchFromGitHub,
  nix-update-script,
}:
buildGo120Module rec {
  pname = "ssv";
  version = "1.3.8";

  src = fetchFromGitHub {
    owner = "bloxapp";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-5JUaJwo8snUrw/Uhk23uiGr+YV4UogiyvLGXXPiYICY=";
  };

  vendorHash = "sha256-paFwSCVQEEkZzd/QHGBfaPvDwSAXYxvS5Cq+N18QTIU=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/ssvnode"];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/bloxapp/ssv";
    platforms = ["x86_64-linux"];
    mainProgram = "ssvnode";
  };
}
