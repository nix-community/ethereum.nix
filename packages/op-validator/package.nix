{
  buildGoModule,
  fetchFromGitHub,
  lib,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-validator";
  version = "1.16.6";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-node/v${version}";
    hash = "sha256-UxpgDtQ6n/iQC4oDPnIlictUmTmUaAKl2RNMGxhYG8Q=";
  };

  sourceRoot = "${src.name}/op-validator";

  proxyVendor = true;
  vendorHash = "sha256-JcRCpMsTgKoibfKG/0MgvNLyZIHwt01sXZiGSQ48GXs=";

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${version}"
    "-X main.GitCommit="
    "-X main.GitDate="
  ];

  doCheck = false;

  # The binary is named 'cmd' after the package, rename to op-validator
  postInstall = ''
    mv $out/bin/cmd $out/bin/op-validator
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    skipAutoUpdate = true;
  };

  meta = with lib; {
    description = "Tool for validating Optimism chain configurations and deployments";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-validator";
    license = licenses.mit;
    mainProgram = "op-validator";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
