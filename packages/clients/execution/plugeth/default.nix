{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "plugeth";
  version = "1.11.4.0.0-dev0";

  src = fetchFromGitHub {
    owner = "openrelayxyz";
    repo = "plugeth";
    rev = "v${version}";
    sha256 = "sha256-8H+eeSEKQg2QWnN0rVggdDmZxjQ5uwnHBH/Z1zyXU1k=";
  };

  vendorSha256 = "sha256-xZZjDiaB+R6tJ8EtklI7JZCkCyhVCe+8eqHg8OMXifQ=";

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
