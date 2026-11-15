{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-proposer";
  version = "1.17.1";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-proposer/v${version}";
    hash = "sha256-srMOEMd0OomoUD9+BaVTQNSfo1Jq4Dll8oeWTi4LONU=";
  };

  sourceRoot = "${src.name}/op-proposer";

  proxyVendor = true;
  vendorHash = "sha256-7lDR3M+I3cmjcjQr1wKzrljFw5drqYAbh7QO/DkhvPk=";

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${version}"
  ];

  doCheck = false;

  # The binary is named 'cmd' after the package, rename to op-proposer
  postInstall = ''
    mv $out/bin/cmd $out/bin/op-proposer
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Optimism proposer service that submits L2 output proposals to L1";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-proposer";
    changelog = "https://github.com/ethereum-optimism/optimism/releases";
    license = licenses.mit;
    mainProgram = "op-proposer";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
