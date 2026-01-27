{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  nodejs,
}:
buildNpmPackage rec {
  pname = "snarkjs";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "iden3";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-9+sph+mca5ToC8l4l3hDdT0jLLeY7fuQi5lbH/BUHOQ=";
  };

  npmDepsHash = "sha256-UfaB+aExi0kSjqiCFErvwTlK9hdq7kxtDUIzNxPx2Uc=";

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "zkSNARK implementation in JavaScript & WASM";
    homepage = "https://github.com/iden3/snarkjs";
    license = with licenses; [ gpl3Only ];
    inherit (nodejs.meta) platforms;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
