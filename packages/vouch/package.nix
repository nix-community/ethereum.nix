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
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-QtH8xi6eXKSxVtx/5lP5BxWN6QOhD064o9r814Jnm0o=";
  };

  vendorHash = "sha256-U62oC4O2noIGXGY5VMxBdnQyQFLqcCy6Ch9BfBjgdfs=";

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
