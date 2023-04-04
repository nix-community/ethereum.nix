{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  libelf,
}:
buildGoModule rec {
  pname = "prysm";
  version = "0.1.0-alpha1";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-zU0WEnm4gn5SSxsF4t4AYmx++RvsiOGQTmAGIltHcfg=";
  };

  vendorSha256 = "sha256-jAMYC9RittkWQBbknJoUuRNMW230C5nf21N3phNea2s=";

  buildInputs = [bls blst libelf];

  subPackages = [
    "cmd/beacon-chain"
  ];

  doCheck = false;

  meta = {
    description = "Our custom Prysm fork for boost relay and builder CL. Sends payload attributes for block building on every slot to trigger building";
    homepage = "https://github.com/flashbots/prysm";
    platforms = ["x86_64-linux"];
  };
}
