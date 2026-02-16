{
  buildGoModule,
  fetchFromGitHub,
  lib,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-supervisor";
  version = "1.16.6";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-node/v${version}";
    hash = "sha256-UxpgDtQ6n/iQC4oDPnIlictUmTmUaAKl2RNMGxhYG8Q=";
  };

  sourceRoot = "${src.name}/op-supervisor";

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

  # The binary is named 'cmd' after the package, rename to op-supervisor
  postInstall = ''
    mv $out/bin/cmd $out/bin/op-supervisor
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    skipAutoUpdate = true;
  };

  meta = with lib; {
    description = "Optimism supervisor for cross-chain message verification";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-supervisor";
    license = licenses.mit;
    mainProgram = "op-supervisor";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
