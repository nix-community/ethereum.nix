{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
  jq,
  yq-go,
  zip,
}:
buildGoModule rec {
  pname = "supersim";
  version = "0.1.0-alpha.60";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "supersim";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-oNA6KmqRP36wNnufXxmFyd3wYKnVLy/eE2Ph42KaTAs=";
  };

  vendorHash = "sha256-RjOuLl9+6FNmvvJQLo0lblG1Ors/N9IDBCQD7Pt1jKk=";

  nativeBuildInputs = [
    jq
    yq-go
    zip
  ];

  # Go vendoring resolves go:embed files from the local Optimism replacement.
  # Generate the ignored bundle before both vendoring and compilation.
  preBuild = ''
    bash contracts/lib/optimism/op-core/superchain/sync-superchain.sh
  '';

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  doCheck = false;

  # Rename cmd binary to supersim
  postInstall = ''
    mv $out/bin/cmd $out/bin/supersim
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Local Multi-L2 Development Environment";
    homepage = "https://github.com/ethereum-optimism/supersim";
    changelog = "https://github.com/ethereum-optimism/supersim/releases";
    license = licenses.mit;
    mainProgram = "supersim";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
