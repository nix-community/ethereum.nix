{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "mev-geth";
  version = "v1.10.23-mev0.7.0";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "mev-geth";
    rev = "${version}";
    sha256 = "sha256-DR9Tg/oMTRcGEccsCc1M4D2pffuM0/qGmtHeaKkXXVQ=";
  };

  vendorSha256 = "sha256-Dj+xN8lr98LJyYr2FwJ7yUIJkUeUrr1fkcbj4hShJI0=";

  ldflags = ["-s" "-w"];

  doCheck = false;

  subPackages = ["cmd/geth"];

  # Following upstream: https://github.com/ethereum/go-ethereum/blob/v1.10.23/build/ci.go#L218
  tags = ["urfave_cli_no_docs"];

  meta = with lib; {
    homepage = "https://github.com/flashbots/mev-geth";
    description = "Go implementation of MEV-Auction for Ethereum";
    license = with licenses; [lgpl3Plus gpl3Plus];
  };
}
