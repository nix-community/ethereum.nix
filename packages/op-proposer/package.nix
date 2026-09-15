{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-proposer";
  version = "1.16.5";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-proposer/v${version}";
    hash = "sha256-wXhnsxWpb36fR1NC4PBF6f98WcDp+740AWDxoN/V8H4=";
  };

  sourceRoot = "${src.name}/op-proposer";

  proxyVendor = true;
  vendorHash = "sha256-83tmZ65862etkscseO9teHVxpaC0BSlEqhlfoK93+Fc=";

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
    license = licenses.mit;
    mainProgram = "op-proposer";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
