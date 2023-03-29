{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "builder";
  version = "1.11.5-0.2.0";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-BpyPxOu9iITGBibjusSQMu6tSJeTXRLSy8Ubb759Gfg=";
  };

  vendorSha256 = "sha256-nja2HGl1Qk3pDYXT+mPo5r+HJKCCZeGEy02AN+byvbE=";

  buildInputs = [blst];

  subPackages = ["cmd/geth"];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Flashbots mev-boost block builder";
    homepage = "https://github.com/flashbots/builder";
    platforms = ["x86_64-linux"];
  };
}
