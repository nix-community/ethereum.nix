{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}: let
  # A list of binaries to put into separate outputs
  bins = [
    "abidump"
    "abigen"
    "bootnode"
    "clef"
    "devp2p"
    "ethkey"
    "evm"
    "faucet"
    "geth"
    "rlpdump"
  ];
in
  buildGoModule rec {
    pname = "geth";
    version = "1.11.0";

    src = fetchFromGitHub {
      owner = "ethereum";
      repo = "go-ethereum";
      rev = "v${version}";
      sha256 = "sha256-QwgFqXTcFZ2zoqlC3oCEgIghJPQ02FwTMbba/DEohwM=";
    };

    vendorSha256 = "sha256-6yLkeT5DrAPUohAmobssKkvxgXI8kACxiu17WYbw+n0=";

    ldflags = ["-s" "-w"];

    doCheck = false;

    # Move binaries to separate outputs and symlink them back to $out
    postInstall = lib.concatStringsSep "\n" (
      builtins.map (bin: "mkdir -p \$${bin}/bin && mv $out/bin/${bin} \$${bin}/bin/ && ln -s \$${bin}/bin/${bin} $out/bin/") bins
    );

    outputs = ["out"] ++ bins;

    subPackages = [
      "cmd/abidump"
      "cmd/abigen"
      "cmd/bootnode"
      "cmd/clef"
      "cmd/devp2p"
      "cmd/ethkey"
      "cmd/evm"
      "cmd/faucet"
      "cmd/geth"
      "cmd/rlpdump"
      "cmd/utils"
    ];

    # Following upstream: https://github.com/ethereum/go-ethereum/blob/v1.10.23/build/ci.go#L218
    tags = ["urfave_cli_no_docs"];

    meta = with lib; {
      homepage = "https://geth.ethereum.org/";
      description = "Official golang implementation of the Ethereum protocol";
      license = with licenses; [lgpl3Plus gpl3Plus];
    };
  }
