{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-conductor";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-conductor/v${version}";
    hash = "sha256-9+jdnQE31D7tC2kmd6rLM8XbyEC5Ohu1llIY0fJ42CM=";
  };

  sourceRoot = "${src.name}/op-conductor";

  proxyVendor = true;
  vendorHash = "sha256-VNWFfmsjG8eh3qBitxmiHnwH3vj2QQ5vOPUt4RqKOEs=";

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${version}"
    "-X main.GitCommit="
    "-X main.GitDate="
  ];

  doCheck = false;

  # The binary is named 'cmd' after the package, rename to op-conductor
  postInstall = ''
    mv $out/bin/cmd $out/bin/op-conductor
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Optimism sequencer conductor for high-availability setups";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-conductor";
    license = licenses.mit;
    mainProgram = "op-conductor";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
