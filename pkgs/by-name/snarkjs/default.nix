{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  nodejs,
}:
buildNpmPackage rec {
  pname = "snarkjs";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "iden3";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-NVi5DCRbf4/nLt8vcKA/X0E7HMgfzJGcgqNJ+5+6wIk=";
  };

  npmDepsHash = "sha256-WYs4qxaV2/UoiAlfRKxeN4KEbzrVXP1QLYcoS+kjp4w=";

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "zkSNARK implementation in JavaScript & WASM";
    homepage = "https://github.com/iden3/snarkjs";
    license = with licenses; [gpl3Only];
    inherit (nodejs.meta) platforms;
  };
}
