{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-batcher";
  version = "1.16.8";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-batcher/v${version}";
    hash = "sha256-W/xlYV05BMZB3xneZDhFKeUWbPBbrgUUdr69vdMssM8=";
  };

  sourceRoot = "${src.name}/op-batcher";

  proxyVendor = true;
  vendorHash = "sha256-Ajh5FEVtptEJLSBWQpr+pib7XTk2bSHXC5z4bh6xQGs=";

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
