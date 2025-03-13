{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nodejs,
}:
buildNpmPackage rec {
  pname = "surya";
  version = "0.4.12";

  src = fetchFromGitHub {
    owner = "consensys";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-RDlQmpzFF4NJUdy27n4Q/UTka433Pn0Q1bNJOMqZtNc=";
  };

  npmDepsHash = "sha256-AMN8PG2+tC064sphLOUsmdDFAdWgZ/y/e0z0mo8uUDs=";

  buildPhase = ''
    runHook preBuild
    npm run prepare
    runHook postBuild
  '';

  meta = with lib; {
    description = "Sūrya, The Sun God: A set of utilities for inspecting the structure of Solidity contracts";
    homepage = "https://github.com/consensys/surya";
    license = with licenses; [asl20];
    inherit (nodejs.meta) platforms;
    maintainers = [];
    mainProgram = "surya";
  };
}
