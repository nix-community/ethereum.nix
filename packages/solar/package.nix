{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  pname = "solar";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-HEd5L9fRIaFDg1DCaeOZQbBkw1XRmuKKm4udK3QpR4Y=";
  };

  cargoHash = "sha256-Cv95IY/wFMhKAhpwZkrrF9KD0k451/vjKvADiuVqyec=";

  cargoBuildFlags = [
    "--package"
    "solar-compiler"
  ];

  # Upstream tests require the Solidity test-suite submodule.
  doCheck = false;

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Blazingly fast Solidity compiler";
    homepage = "https://github.com/paradigmxyz/solar";
    changelog = "https://github.com/paradigmxyz/solar/releases";
    license = with licenses; [
      mit
      asl20
    ];
    mainProgram = "solar";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
