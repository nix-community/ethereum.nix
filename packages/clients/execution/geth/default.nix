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
    "geth"
    "p2psim"
    "rlpdump"
  ];
in
  buildGoModule rec {
    pname = "geth";
    version = "1.13.10";

    src = fetchFromGitHub {
      owner = "ethereum";
      repo = "go-ethereum";
      rev = "v${version}";
      hash = "sha256-HFAf5fjYiRx6OEbqdtgaan8bqZPHazYKWG2Ty+WhNu8=";
    };

    vendorHash = "sha256-w4WUDLzpr0VTwLK84/Yq4ia3Q1XhxDttzQ5RGg2FQGU=";

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
      "cmd/geth"
      "cmd/p2psim"
      "cmd/rlpdump"
      "cmd/utils"
    ];

    # Following upstream: https://github.com/ethereum/go-ethereum/blob/v1.10.23/build/ci.go#L218
    tags = ["urfave_cli_no_docs"];

    meta = with lib; {
      description = "Official golang implementation of the Ethereum protocol";
      homepage = "https://geth.ethereum.org/";
      license = with licenses; [lgpl3Plus gpl3Plus];
      mainProgram = "geth";
      platforms = ["x86_64-linux" "aarch64-linux"];
    };
  }
