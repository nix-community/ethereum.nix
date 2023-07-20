{
  bls,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "eth2-testnet-genesis";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "protolambda";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-dgn6kI6U+ZsztAaAtjjvAstasjy8LQo+OOyOySKRfCk=";
  };

  vendorHash = "sha256-iXJDZtm68Qk1Za8+Bsk140hyl/GeyXlj47PBEZw1tro=";

  buildInputs = [bls];

  subPackages = ["."];

  ldflags = ["-s" "-w"];

  meta = {
    description = "Create a genesis state for an Eth2 testnet";
    homepage = "https://github.com/protolambda/eth2-testnet-genesis";
    mainProgram = "eth2-testnet-genesis";
    platforms = ["x86_64-linux"];
  };
}
