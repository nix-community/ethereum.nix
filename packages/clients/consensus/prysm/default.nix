{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  libelf,
}:
buildGoModule rec {
  pname = "prysm";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-cLOcPE8zXypDev2AnRdnkDzwD88lnX1TOM8kC+8LA3M=";
  };

  vendorSha256 = "sha256-U9PrDKTuQ46qZqUN8Wlh34sF7Uh2WsjouHIQfPw0Ypo=";

  buildInputs = [bls blst libelf];

  subPackages = [
    "cmd/beacon-chain"
    "cmd/client-stats"
    "cmd/prysmctl"
    "cmd/validator"
  ];

  doCheck = false;

  meta = {
    description = "Go implementation of Ethereum proof of stake";
    homepage = "https://github.com/prysmaticlabs/prysm";
    platforms = ["x86_64-linux"];
  };
}
