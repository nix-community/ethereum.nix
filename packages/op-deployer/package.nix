{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-deployer";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-deployer/v${version}";
    hash = "sha256-eY8rstFPnuZX3cPAPmn+vaL5263SEX9SSmw5KAji+C4=";
  };

  sourceRoot = "${src.name}/op-deployer";

  proxyVendor = true;
  vendorHash = "sha256-qfGppuVVV1aplsLqES7kZ9qL2w4/902pMOQJs8PEU18=";

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
    license = licenses.mit;
    mainProgram = "op-deployer";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
