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
  version = "1.13.2";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-JPRR96dH+OwUXeOCwnqsvPjMdIElt0OlZEcfk5vcPJ4=";
  };

  vendorHash = "sha256-K6ljtqWpc2KyZ/TzyDkDA7RajrcoRcKO/36FIlITEuM=";

  proxyVendor = true;

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
    changelog = "https://github.com/attestantio/vouch/releases";
    license = lib.licenses.asl20;
    mainProgram = "vouch";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
