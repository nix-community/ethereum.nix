{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "zcli";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "protolambda";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-uQ67Gp1Gs7Fl1fPDe2jHc84DV9RtBRz0EaD8WIn113c=";
  };

  vendorSha256 = "sha256-+5l35M7wsCOOLdVUY8nr+O7693TmiuVHD+2AFCltFRc=";

  subPackages = ["."];

  meta = with lib; {
    homepage = "https://github.com/protolambda/zcli";
    description = "Eth2 CLI debugging tool";
    platforms = ["x86_64-linux"];
  };
}
