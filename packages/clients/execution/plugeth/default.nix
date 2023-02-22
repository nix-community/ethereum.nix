{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "plugeth";
  version = "1.10.25.0.0";

  src = fetchFromGitHub {
    owner = "openrelayxyz";
    repo = "plugeth";
    rev = "v${version}";
    sha256 = "sha256-sibt+rud2eNskC4TXbWUOCmvzpwUEdTSi/WQiu4Mwpc=";
  };

  vendorSha256 = "sha256-xP4jbaQUB3VvyD8sktfFpTDUZVEKtskqkVb/GkTYp54=";

  ldflags = ["-s" "-w"];

  doCheck = false;

  subPackages = ["cmd/geth"];

  # Following upstream: https://github.com/ethereum/go-ethereum/blob/v1.10.23/build/ci.go#L218
  tags = ["urfave_cli_no_docs"];

  meta = with lib; {
    homepage = "https://github.com/openrelayxyz/plugeth";
    description = "PluGeth: The extensible Geth fork to end all Geth forks.";
    license = with licenses; [lgpl3Plus gpl3Plus];
    platforms = ["x86_64-linux"];
  };
}
