{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
  superchainConfigsHook,
}:
buildGoModule rec {
  pname = "op-deployer";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-deployer/v${version}";
    # The superchain configs live in the superchain-registry submodule, which is
    # needed to regenerate the embedded superchain-configs.zip (see superchainConfigsHook).
    fetchSubmodules = true;
    hash = "sha256-uChBJr2In5YG85XuIFhYShjAnoMuTE9AjUI62xA8XHs=";
  };

  sourceRoot = "${src.name}/op-deployer";

  proxyVendor = true;
  vendorHash = "sha256-+RSlcvjgo+Wu87bW3BiIiCPNumqTUUFK0mfXNShuP8k=";

  nativeBuildInputs = [ superchainConfigsHook ];

  subPackages = [ "cmd/op-deployer" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ethereum-optimism/optimism/op-deployer/pkg/deployer/version.Version=v${version}"
    "-X github.com/ethereum-optimism/optimism/op-deployer/pkg/deployer/version.Meta="
  ];

  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Optimism deployer tool for deploying OP Stack chains";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-deployer";
    changelog = "https://github.com/ethereum-optimism/optimism/releases";
    license = licenses.mit;
    mainProgram = "op-deployer";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
