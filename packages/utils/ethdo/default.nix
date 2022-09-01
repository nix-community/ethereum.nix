{
  buildGoModule,
  fetchFromGitHub,
  clang,
  mcl,
  bls,
  ...
}:
buildGoModule rec {
  pname = "ethdo";
  version = "1.25.3";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = "ethdo";
    rev = "v${version}";
    hash = "sha256-bjkG8aWy90amIBtsBVKGWb244LySkyWV/9yi+inpLtM=";
  };

  runVend = true;
  vendorSha256 = "sha256-Kn4eaZMpIpXARf+jeXk9fndri2VYihm3WcxP1ApPRLs=";

  nativeBuildInputs = [clang];
  buildInputs = [mcl bls];

  doCheck = false;
}
