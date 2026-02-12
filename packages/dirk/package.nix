{
  bls_1_86,
  buildGoModule,
  fetchFromGitHub,
  lib,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "dirk";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-uYS1yaXsooUsx84EPAV1+pT6d9yK3y9SqpsGQwtKmR8=";
  };

  runVend = true;
  vendorHash = "sha256-SlYg3QFHXh6jlZFGIFLivydGVZHocF/CZHbSg4Q/4r0=";

  buildInputs = [
    mcl
    bls_1_86
  ];

  doCheck = false;

  passthru.category = "Validators";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "An Ethereum 2 distributed remote keymanager, focused on security and long-term performance of signing operations";
    homepage = "https://github.com/attestantio/dirk";
    license = lib.licenses.asl20;
    mainProgram = "dirk";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
