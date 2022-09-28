{
  mkGeth,
  blst,
}:
mkGeth {
  name = "mev-boost";
  version = "1.3.2";
  owner = "flashbots";
  repo = "mev-boost";
  sha256 = "sha256-tqiu5wJsgwdFJH1gvbCqgCstMMWA/As7tSNBwv9rMdA=";
  vendorSha256 = "sha256-qKlltwacgCNfuMcnkCwhOZtIRqDJTarOd1Vf9C6oIk4=";
  subPackages = ["cmd/mev-boost"];
  buildInputs = [blst];
  bins = [];
}
