{
  buildGoModule,
  fetchFromGitHub,
  clang,
  mcl,
  bls,
  lib,
  ...
}:
buildGoModule rec {
  pname = "ethdo";
  version = "1.33.0";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = "ethdo";
    rev = "v${version}";
    hash = "sha256-h+pkdzyTQWaVHkipfDf+tDJO5Cq/2sv1iJknaV0aKmQ=";
  };

  runVend = true;
  vendorHash = "sha256-AhaOe8OxudnE8RSgsoN08dRVyue0UrCOPwL+7x63jqE=";

  nativeBuildInputs = [clang];
  buildInputs = [mcl bls];

  doCheck = false;

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum 2";
    homepage = "https://github.com/wealdtech/ethdo";
    license = licenses.apsl20;
    mainProgram = "ethdo";
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
