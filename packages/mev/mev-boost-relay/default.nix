{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mev-boost-relay";
  version = "0.21";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-pi0wTdzN0HM7w+4QBFvNRNUM+vQd2pwfWh0s0YmSIow=";
  };

  vendorSha256 = "sha256-89GkgA4CREcqm9kYhw/mYM67/9qqyo7Bw+42Tfv3jIY=";

  buildInputs = [blst];

  subPackages = ["."];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  meta = {
    description = "MEV-Boost Relay for Ethereum proposer/builder separation (PBS)";
    homepage = "https://github.com/flashbots/mev-boost-relay";
    mainProgram = "mev-boost-relay";
    platforms = ["x86_64-linux"];
  };
}
