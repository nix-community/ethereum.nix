{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
  jq,
  yq-go,
  zip,
}:
buildGoModule rec {
  pname = "op-deployer";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-deployer/v${version}";
    # The superchain configs live in the superchain-registry submodule, which is
    # needed to regenerate the embedded superchain-configs.zip (see preBuild).
    fetchSubmodules = true;
    hash = "sha256-uChBJr2In5YG85XuIFhYShjAnoMuTE9AjUI62xA8XHs=";
  };

  sourceRoot = "${src.name}/op-deployer";

  proxyVendor = true;
  vendorHash = "sha256-+RSlcvjgo+Wu87bW3BiIiCPNumqTUUFK0mfXNShuP8k=";

  # op-core/superchain embeds superchain-configs.zip via //go:embed. The zip is
  # gitignored and regenerated from the superchain-registry submodule; init()
  # panics unless the bundle matches the committed .sha256. Rebuild it before
  # compiling so the embed succeeds (the script asserts the .sha256 match).
  nativeBuildInputs = [
    jq
    yq-go
    zip
  ];

  preBuild = ''
    # unpackPhase only makes sourceRoot (op-deployer) writable; the script copies
    # from and writes into these sibling trees, so make them writable too.
    chmod -R u+w ../op-core ../superchain-registry
    patchShebangs ../op-core/superchain/sync-superchain.sh
    bash ../op-core/superchain/sync-superchain.sh
  '';

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
