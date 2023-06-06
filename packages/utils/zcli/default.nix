{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "zcli";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "protolambda";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-uQ67Gp1Gs7Fl1fPDe2jHc84DV9RtBRz0EaD8WIn113c=";
  };

  vendorHash = "sha256-+5l35M7wsCOOLdVUY8nr+O7693TmiuVHD+2AFCltFRc=";

  subPackages = ["."];

  meta = {
    description = "Eth2 CLI debugging tool";
    homepage = "https://github.com/protolambda/zcli";
    mainProgram = "zcli";
    platforms = ["x86_64-linux"];
  };
}
