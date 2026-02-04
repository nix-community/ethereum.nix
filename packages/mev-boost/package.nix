{
  blst,
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "mev-boost";
  version = "1.11.0";
  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-uEIZojmzSVyF+ZOQsSqZA0MB2cT8I/JHGfgKVI48PIk=";
  };

  vendorHash = "sha256-dIc0ZHTx+7P621FvfDKlItc/FazUpwxRmDQF2SNVIwA=";

  buildInputs = [ blst ];

  subPackages = [ "cmd/mev-boost" ];

  passthru = {
    category = "MEV";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "MEV-Boost allows proof-of-stake Ethereum consensus clients to source blocks from a competitive builder marketplace";
    homepage = "https://github.com/flashbots/mev-boost";
    license = lib.licenses.mit;
    mainProgram = "mev-boost";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
