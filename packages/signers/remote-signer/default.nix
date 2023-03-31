{
  blst,
  buildGoModule,
  fetchFromGitHub,
  lib,
  mcl,
}:
buildGoModule rec {
  pname = "remote-signer";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "3d164b450a9b9c68ab4dd0fa74d0ba78f1eaae9f"; # latest main version
    sha256 = "sha256-/lpdsBOOjFA46WPiQFc48sNm/yBL6Umw8okN9w4npX0=";
  };

  vendorSha256 = "sha256-cBYd/GmVdv4FEPgxucNViv1x7KXRu1fWpw3Hlv4ThPQ=";

  subPackages = ["."];

  buildInputs = [blst mcl];

  ldflags = ["-s" "-w"];

  meta = with lib; {
    homepage = "https://github.com/prysmaticlabs/remote-signer";
    description = "Remote signer server reference implementation for eth2";
    platforms = ["x86_64-linux"];
  };
}
