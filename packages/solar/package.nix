{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  pname = "solar";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-/Mifk6mnQiFWMFD0hTDO5FNXVWflQIFxsn7yovYAM0M=";
  };

  cargoHash = "sha256-LKpJXnq3GVbSBrGqjIGVMVkFb3yAc6kukp0/5KbH59I=";

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
    license = with licenses; [
      mit
      asl20
    ];
    mainProgram = "solar";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
