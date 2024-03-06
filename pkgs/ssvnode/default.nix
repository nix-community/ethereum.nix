{
  bls,
  mcl,
  buildGo120Module,
  fetchFromGitHub,
}:
buildGo120Module rec {
  pname = "ssv";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "bloxapp";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-opd9o4ntLT047rarRQxNxvZp/4vNGAgSbuLhf4ZUBTo=";
  };

  vendorHash = "sha256-angs1oykJWDjkBZSsWnt+JcyhZIDPbSgkQ3TD/CzXQA=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/ssvnode"];

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/bloxapp/ssv";
    platforms = ["x86_64-linux"];
    mainProgram = "ssvnode";
  };
}
