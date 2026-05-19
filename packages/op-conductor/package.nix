{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-conductor";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-conductor/v${version}";
    hash = "sha256-i872RAkjZr/KN5qCvb0Mj0tGqmULcpFOvOpVDTJS4LY=";
  };

  sourceRoot = "${src.name}/op-conductor";

  proxyVendor = true;
  vendorHash = "sha256-uqOIItBtQ92W9Ikw1jWxzQ/3qkuBAncclLPv7GHr9Gs=";

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
