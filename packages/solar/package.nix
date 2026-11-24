{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  pname = "solar";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-+/BXXtnAHINRdesI/07bYuDmquTy1E0cmsc+8rnAgvc=";
  };

  cargoHash = "sha256-/FjQVfl+7IlbUai/DilKpPRGAdqIeSoM3f+HL6rXc2A=";

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
