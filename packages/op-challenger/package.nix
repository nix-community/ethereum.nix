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
  pname = "op-challenger";
  version = "1.9.5";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-challenger/v${version}";
    # The superchain configs live in the superchain-registry submodule, which is
    # needed to regenerate the embedded superchain-configs.zip (see preBuild).
    fetchSubmodules = true;
    hash = "sha256-N3W4+iA27SBPLv7uw4864UQhi4DkyQfO7nKKCXobNd8=";
  };

  sourceRoot = "${src.name}/op-challenger";

  proxyVendor = true;
  vendorHash = "sha256-83tmZ65862etkscseO9teHVxpaC0BSlEqhlfoK93+Fc=";

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
    # unpackPhase only makes sourceRoot (op-challenger) writable; the script
    # copies from and writes into these sibling trees, so make them writable too.
    chmod -R u+w ../op-core ../superchain-registry
    patchShebangs ../op-core/superchain/sync-superchain.sh
    bash ../op-core/superchain/sync-superchain.sh
  '';

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
