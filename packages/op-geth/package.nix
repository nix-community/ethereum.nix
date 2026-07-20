{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-geth";
  version = "1.101702.2";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "op-geth";
    rev = "v${version}";
    hash = "sha256-PrAaWh1h287K3vHLjh5X6BotbGeDSrfSgIAgl+TOTmM=";
  };

  proxyVendor = true;
  vendorHash = "sha256-F8FL3qqSW49/YXRlMyRhmI0Q3Bwu6y8VVDqRFLd87CQ=";

  subPackages = [ "cmd/geth" ];

  # Following upstream geth: https://github.com/ethereum/go-ethereum/blob/v1.10.23/build/ci.go#L218
  tags = [ "urfave_cli_no_docs" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ethereum/go-ethereum/version.gitTag=v${version}"
  ];

  doCheck = false;

  # Rename geth binary to op-geth to avoid conflicts with regular geth
  postInstall = ''
    mv $out/bin/geth $out/bin/op-geth
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Optimism implementation of the Ethereum protocol";
    homepage = "https://github.com/ethereum-optimism/op-geth";
    license = with licenses; [
      lgpl3Plus
      gpl3Plus
    ];
    mainProgram = "op-geth";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
