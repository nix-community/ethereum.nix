{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "supersim";
  version = "0.1.0-alpha.59";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "supersim";
    rev = version;
    hash = "sha256-oWQ1OJI3WE1W5Hxz5qnmRDrP79is4R/t0584QGWoPr8=";
  };

  vendorHash = "sha256-ENr4xKASnF2uWkpJoxHcaM2Tbq6L4lbZPp7v5ucFxiI=";

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
    license = licenses.mit;
    mainProgram = "supersim";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
