{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
  superchainConfigsHook,
}:
buildGoModule rec {
  pname = "op-challenger";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-challenger/v${version}";
    # The superchain configs live in the superchain-registry submodule, which is
    # needed to regenerate the embedded superchain-configs.zip (see superchainConfigsHook).
    fetchSubmodules = true;
    hash = "sha256-89U9JmKfBCmbbm6fo1hsMNb30XND1GM+BGvzUpCX9W0=";
  };

  sourceRoot = "${src.name}/op-challenger";

  proxyVendor = true;
  vendorHash = "sha256-83tmZ65862etkscseO9teHVxpaC0BSlEqhlfoK93+Fc=";

  nativeBuildInputs = [ superchainConfigsHook ];

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
    changelog = "https://github.com/ethereum-optimism/optimism/releases";
    license = licenses.mit;
    mainProgram = "op-challenger";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
