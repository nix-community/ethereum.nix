{
  bls,
  blst,
  buildGo121Module,
  fetchFromGitHub,
  libelf,
}:
buildGo121Module rec {
  pname = "prysm";
  version = "4.0.0-boost0.2.0";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-HIYfFMRvfZoceeWGzkJFY1TeVT9QRbDxdtnx6HpEorc=";
  };

  vendorHash = "sha256-U9PrDKTuQ46qZqUN8Wlh34sF7Uh2WsjouHIQfPw0Ypo=";

  buildInputs = [bls blst libelf];

  subPackages = [
    "cmd/beacon-chain"
  ];

  doCheck = false;

  meta = {
    description = "Our custom Prysm fork for boost relay and builder CL. Sends payload attributes for block building on every slot to trigger building";
    homepage = "https://github.com/flashbots/prysm";
    mainProgram = "beacon-chain";
    platforms = ["x86_64-linux"];
  };
}
