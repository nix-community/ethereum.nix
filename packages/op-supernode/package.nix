{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
  superchainConfigsHook,
}:
buildGoModule rec {
  pname = "op-supernode";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-supernode/v${version}";
    # The superchain configs live in the superchain-registry submodule, which is
    # needed to regenerate the embedded superchain-configs.zip (see superchainConfigsHook).
    fetchSubmodules = true;
    hash = "sha256-+SVczubN9OrDwl5EmQG4Nv+8AWIYTpmwk5JbyKibWek=";
  };

  sourceRoot = "${src.name}/op-supernode";

  proxyVendor = true;
  vendorHash = "sha256-H51p3C6DqnM5P5pUQH/QYlVAxHomfF6nu/bkL3OQdZE=";

  nativeBuildInputs = [ superchainConfigsHook ];

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${version}"
    "-X main.GitCommit="
    "-X main.GitDate="
  ];

  doCheck = false;

  # The binary is named 'cmd' after the package, rename to op-supernode
  postInstall = ''
    mv $out/bin/cmd $out/bin/op-supernode
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Optimism supernode that runs multiple OP Stack chains in a single process";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-supernode";
    changelog = "https://github.com/ethereum-optimism/optimism/releases";
    license = licenses.mit;
    maintainers = with maintainers; [ selfuryon ];
    mainProgram = "op-supernode";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
