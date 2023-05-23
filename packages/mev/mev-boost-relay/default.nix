{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mev-boost-relay";
  version = "1.15.3";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-YYB0FWDa32seAkDh48cTipy6gVOIO9fxQxHthaTEihE=";
  };

  vendorSha256 = "sha256-OorRKPkpRFga+Uw0sWRHSRsYD44uMAZLtqR6CqZRPj8=";

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
