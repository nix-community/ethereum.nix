{
  buildGoModule,
  fetchFromGitHub,
  mcl,
  bls,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-EPBMFff9NoGy8L+aNilVZ2oHo2QcgwLyPxhRZDY6QrY=";
  };

  vendorHash = "sha256-sRoLkvULqYtA76TqgoEQK7CS59oalGH5V0SXlvlHWGw=";

  runVend = true;

  buildInputs = [mcl bls];

  doCheck = false;

  meta = {
    description = "An Ethereum 2 multi-node validator client";
    homepage = "https://github.com/attestantio/vouch";
    mainProgram = "vouch";
    platforms = ["x86_64-linux"];
  };
}
