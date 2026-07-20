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
  pname = "op-batcher";
  version = "1.16.11";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-batcher/v${version}";
    # The superchain configs live in the superchain-registry submodule, which is
    # needed to regenerate the embedded superchain-configs.zip (see preBuild).
    fetchSubmodules = true;
    hash = "sha256-3KLD28XJGmQ91LJ7bA/uYTf9mf1zwjoi5CHGpQllXQ8=";
  };

  sourceRoot = "${src.name}/op-batcher";

  proxyVendor = true;
  vendorHash = "sha256-2WAgQJ6qJI4gZQSEEi5pOclYApUgnc1IQv6tSmj17xI=";

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
    # unpackPhase only makes sourceRoot (op-batcher) writable; the script copies
    # from and writes into these sibling trees, so make them writable too.
    chmod -R u+w ../op-core ../superchain-registry
    patchShebangs ../op-core/superchain/sync-superchain.sh
    bash ../op-core/superchain/sync-superchain.sh
  '';

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${version}"
  ];

  doCheck = false;

  # The binary is named 'cmd' after the package, rename to op-batcher
  postInstall = ''
    mv $out/bin/cmd $out/bin/op-batcher
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Optimism batcher service that submits L2 transaction batches to L1";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-batcher";
    license = licenses.mit;
    mainProgram = "op-batcher";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
