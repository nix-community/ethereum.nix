{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mev-boost-relay";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-B8K8d8DB1Fw6Vr4+/pYUINOX1/xI+6TJq9Lskg2r0uQ=";
  };

  vendorSha256 = "sha256-0WrkYgpiwLp+iEFIrU7yeftNZnLNQt3RuYSzB0QwZ3k=";

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
    platforms = ["x86_64-linux"];
  };
}
