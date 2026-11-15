{
  bls_1_86,
  buildGoModule,
  clang,
  fetchFromGitHub,
  lib,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "eth2-val-tools";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "protolambda";
    repo = "eth2-val-tools";
    rev = "v${version}";
    hash = "sha256-Q3cHheho7L+3i7dAy8VZKrMU64+mpzhU5YxWVkpNEY4=";
  };

  runVend = true;
  vendorHash = "sha256-MrZC7QzZuVVd5QWHXLZZGui1J+35TMgGPFXKGR2sLHg=";

  nativeBuildInputs = [ clang ];
  buildInputs = [
    mcl
    bls_1_86
  ];

  doCheck = false;

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Some experimental tools to manage validators";
    homepage = "https://github.com/protolambda/eth2-val-tools";
    changelog = "https://github.com/protolambda/eth2-val-tools/releases";
    license = licenses.mit;
    mainProgram = "eth2-val-tools";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
