{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
  superchainConfigsHook,
}:
buildGoModule rec {
  pname = "op-node";
  version = "1.19.9";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-node/v${version}";
    # The superchain configs live in the superchain-registry submodule, which is
    # needed to regenerate the embedded superchain-configs.zip (see superchainConfigsHook).
    fetchSubmodules = true;
    hash = "sha256-+SVczubN9OrDwl5EmQG4Nv+8AWIYTpmwk5JbyKibWek=";
  };

  sourceRoot = "${src.name}/op-node";

  proxyVendor = true;
  vendorHash = "sha256-H51p3C6DqnM5P5pUQH/QYlVAxHomfF6nu/bkL3OQdZE=";

  nativeBuildInputs = [ superchainConfigsHook ];

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
    changelog = "https://github.com/ethereum-optimism/optimism/releases";
    license = licenses.mit;
    mainProgram = "op-node";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
