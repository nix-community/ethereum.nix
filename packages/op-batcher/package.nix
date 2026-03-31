{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-batcher";
  version = "1.16.6";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-batcher/v${version}";
    hash = "sha256-s6Xk6kHxF0sOl1KPFhPms9zjVRg8CkNUbEsW7WwWblc=";
  };

  sourceRoot = "${src.name}/op-batcher";

  proxyVendor = true;
  vendorHash = "sha256-xmPWst13JApkr8QRplK0cuDZNDfqx7E52vxdx2qA3gE=";

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
