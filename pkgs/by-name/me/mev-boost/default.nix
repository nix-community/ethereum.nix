{
  blst,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "mev-boost";
  version = "1.9-rc3";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-wBIK0J1KJpJPHjjsR8NeKeJfBjWMjc6Dbw8CZ+sOlfc=";
  };

  vendorHash = "sha256-V1KEMgS3dlPZjHZKLUKdFvbRT7Iq5h38wqDsHMXP/rU=";

  buildInputs = [blst];

  subPackages = ["cmd/mev-boost"];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "MEV-Boost allows proof-of-stake Ethereum consensus clients to source blocks from a competitive builder marketplace";
    homepage = "https://github.com/flashbots/mev-boost";
    mainProgram = "mev-boost";
    platforms = ["x86_64-linux"];
  };
}
