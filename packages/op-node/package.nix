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
  pname = "op-node";
  version = "1.19.3";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-node/v${version}";
    # The superchain configs live in the superchain-registry submodule, which is
    # needed to regenerate the embedded superchain-configs.zip (see preBuild).
    fetchSubmodules = true;
    hash = "sha256-aWg/sNWheUNQerTcqbHN3V6TjHoPH/19Opd8Jb05kvk=";
  };

  sourceRoot = "${src.name}/op-node";

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
    # unpackPhase only makes sourceRoot (op-node) writable; the script copies
    # from and writes into these sibling trees, so make them writable too.
    chmod -R u+w ../op-core ../superchain-registry
    patchShebangs ../op-core/superchain/sync-superchain.sh
    bash ../op-core/superchain/sync-superchain.sh
  '';

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ethereum-optimism/optimism/op-node/version.Version=v${version}"
    "-X github.com/ethereum-optimism/optimism/op-node/version.Meta="
  ];

  doCheck = false;

  # The binary is named 'cmd' after the package, rename to op-node
  postInstall = ''
    mv $out/bin/cmd $out/bin/op-node
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Optimism rollup node that derives the L2 chain from L1";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-node";
    license = licenses.mit;
    mainProgram = "op-node";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
