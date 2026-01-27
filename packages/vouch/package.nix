{
  bls,
  buildGoModule,
  fetchFromGitHub,
  lib,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-+q2Mbp3MZsd+cni90Vq0Q09XeYyXzDNj1Vw4Z/Kz1/M=";
  };

  vendorHash = "sha256-LAthOCmfthYI5qsXpsD5rUGQo3YLCqnPBoTBDdmBBkQ=";

  runVend = true;

  buildInputs = [
    mcl
    bls
  ];

  doCheck = false;

  passthru = {
    category = "Validators";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "An Ethereum 2 multi-node validator client";
    homepage = "https://github.com/attestantio/vouch";
    license = lib.licenses.asl20;
    mainProgram = "vouch";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
