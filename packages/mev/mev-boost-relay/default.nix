{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mev-boost-relay";
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-C5A8VI+dNYoTiYVuKDTr4BAHqmZ1aNCXCbc970OYNLQ=";
  };

  vendorSha256 = "sha256-9PKCyeG8+SLI5KWSQAAXuXr3YvkdjyvbwstpHUCXRHU=";

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
