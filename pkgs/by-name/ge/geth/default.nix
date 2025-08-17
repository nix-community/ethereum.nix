{ buildGoModule
, fetchFromGitHub
, lib
, nix-update-script
,
}:
let
  # A list of binaries to put into separate outputs
  bins = [
    "abidump"
    "abigen"
    "blsync"
    "bootnode"
    "clef"
    "devp2p"
    "era"
    "ethkey"
    "evm"
    "geth"
    "rlpdump"
  ];
in
buildGoModule rec {
  pname = "geth";
  version = "1.16.2";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "go-ethereum";
    rev = "v${version}";
    hash = "sha256-12bmK9OYYIDBeN52dQElnDaOcWOzwvjpAZmzHH8IHvw=";
  };

  proxyVendor = true;
  vendorHash = "sha256-i1PhF1DFdt2X4faxe5+iYsPIyco0Xb6stOzaCy6JIto=";

  ldflags = [ "-s" "-w" ];

  doCheck = false;

  # Move binaries to separate outputs and symlink them back to $out
  postInstall = lib.concatStringsSep "\n" (
    builtins.map (bin: "mkdir -p \$${bin}/bin && mv $out/bin/${bin} \$${bin}/bin/ && ln -s \$${bin}/bin/${bin} $out/bin/") bins
  );

  outputs = [ "out" ] ++ bins;

  subPackages = [
    "cmd/abidump"
    "cmd/abigen"
    "cmd/blsync"
    "cmd/clef"
    "cmd/devp2p"
    "cmd/era"
    "cmd/ethkey"
    "cmd/evm"
    "cmd/geth"
    "cmd/rlpdump"
    "cmd/utils"
  ];

  # Following upstream: https://github.com/ethereum/go-ethereum/blob/v1.10.23/build/ci.go#L218
  tags = [ "urfave_cli_no_docs" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Official golang implementation of the Ethereum protocol";
    homepage = "https://geth.ethereum.org/";
    license = with licenses; [ lgpl3Plus gpl3Plus ];
    mainProgram = "geth";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
