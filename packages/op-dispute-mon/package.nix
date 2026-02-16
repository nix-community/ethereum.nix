{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-dispute-mon";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-dispute-mon/v${version}";
    hash = "sha256-AIfaiwCTpiOm8o/2qEmeRgaeNo9TSaJi2s3EG9Ed3kQ=";
  };

  sourceRoot = "${src.name}/op-dispute-mon";

  proxyVendor = true;
  vendorHash = "sha256-ZkgQ3NRqHk34bTkxuWvp7DAw+a70VTRCa5AbclnyPOg=";

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
