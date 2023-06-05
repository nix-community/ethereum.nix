{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mev-boost-relay";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-3Nshb4RpAs3093d7bTCdt0dTX+55DaIzAY4QzCJEcA4=";
  };

  vendorHash = "sha256-OorRKPkpRFga+Uw0sWRHSRsYD44uMAZLtqR6CqZRPj8=";

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
