{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-dispute-mon";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-dispute-mon/v${version}";
    hash = "sha256-wXhnsxWpb36fR1NC4PBF6f98WcDp+740AWDxoN/V8H4=";
  };

  sourceRoot = "${src.name}/op-dispute-mon";

  proxyVendor = true;
  vendorHash = "sha256-83tmZ65862etkscseO9teHVxpaC0BSlEqhlfoK93+Fc=";

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ethereum-optimism/optimism/op-dispute-mon/version.Version=v${version}"
    "-X github.com/ethereum-optimism/optimism/op-dispute-mon/version.Meta="
  ];

  doCheck = false;

  # The binary is named 'cmd' after the package, rename to op-dispute-mon
  postInstall = ''
    mv $out/bin/cmd $out/bin/op-dispute-mon
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Optimism dispute monitor that tracks and reports on fault proof disputes";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-dispute-mon";
    license = licenses.mit;
    mainProgram = "op-dispute-mon";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
