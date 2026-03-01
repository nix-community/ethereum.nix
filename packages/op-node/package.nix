{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-node";
  version = "1.16.7";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-node/v${version}";
    hash = "sha256-XOBaQIxGdqxm3tkhjQK2uucAsqRSjXL9tb5tU9uW7hQ=";
  };

  sourceRoot = "${src.name}/op-node";

  proxyVendor = true;
  vendorHash = "sha256-VNWFfmsjG8eh3qBitxmiHnwH3vj2QQ5vOPUt4RqKOEs=";

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
