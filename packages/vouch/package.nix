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
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Pc6C5/XE46fBhDw2o7ZHOhlqN2nyLiG2g4Z6WShymgM=";
  };

  vendorHash = "sha256-EsSKyXQMy4KG5svENw5SVYQnj5huW2Lb+EFVehdJsYM=";

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
