{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-challenger";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-challenger/v${version}";
    hash = "sha256-AIfaiwCTpiOm8o/2qEmeRgaeNo9TSaJi2s3EG9Ed3kQ=";
  };

  sourceRoot = "${src.name}/op-challenger";

  proxyVendor = true;
  vendorHash = "sha256-ZkgQ3NRqHk34bTkxuWvp7DAw+a70VTRCa5AbclnyPOg=";

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ethereum-optimism/optimism/op-challenger/version.Version=v${version}"
    "-X github.com/ethereum-optimism/optimism/op-challenger/version.Meta="
  ];

  doCheck = false;

  # The binary is named 'cmd' after the package, rename to op-challenger
  postInstall = ''
    mv $out/bin/cmd $out/bin/op-challenger
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Optimism fault proof challenger service that monitors and disputes invalid claims";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-challenger";
    license = licenses.mit;
    mainProgram = "op-challenger";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
