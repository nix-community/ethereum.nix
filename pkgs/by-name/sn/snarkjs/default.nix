{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nodejs,
}:
buildNpmPackage rec {
  pname = "snarkjs";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "iden3";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-1bsYaVw07k5gOovA3hUb85k24PBbmLYbTPN4HKTR62w=";
  };

  npmDepsHash = "sha256-cASHuNEH5g6D1CSScp12JQ4in8dddG4EEFW5INHLMg8=";

  meta = with lib; {
    description = "zkSNARK implementation in JavaScript & WASM";
    homepage = "https://github.com/iden3/snarkjs";
    license = with licenses; [gpl3Only];
    inherit (nodejs.meta) platforms;
  };
}
