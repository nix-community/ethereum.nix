{
  bls_1_86,
  buildGoModule,
  fetchFromGitHub,
  lib,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.13.1";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-VYcBHZp4GPdZmN+Da9ajaKOBCqD7uecoPMenRp6bx3Y=";
  };

  vendorHash = "sha256-SeizeG2dul6bVnr1vuro+0Xj4guxKOTOwLLV14yEvms=";

  runVend = true;

  buildInputs = [
    mcl
    bls_1_86
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
