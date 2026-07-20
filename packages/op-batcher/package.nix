{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-batcher";
  version = "1.16.11";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-batcher/v${version}";
    hash = "sha256-gmVD+HSNVUAkcS72uNwwi2gRzJRd4Ulf3YyVLUH/VBo=";
  };

  sourceRoot = "${src.name}/op-batcher";

  proxyVendor = true;
  vendorHash = "sha256-2WAgQJ6qJI4gZQSEEi5pOclYApUgnc1IQv6tSmj17xI=";

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
