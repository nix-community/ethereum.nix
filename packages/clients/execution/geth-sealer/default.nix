{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "geth-sealer";
  version = "master";

  src = fetchFromGitHub {
    owner = "manifoldfinance";
    repo = "geth-sealer";
    rev = "${version}";
    sha256 = "sha256-nS4xpp9etSuay3L4RD3Z00RLK3O/Y/2bIoLyw7FPtOY=";
  };

  vendorSha256 = "sha256-Dj+xN8lr98LJyYr2FwJ7yUIJkUeUrr1fkcbj4hShJI0=";

  ldflags = ["-s" "-w"];

  doCheck = false;

  subPackages = ["cmd/geth"];

  # Following upstream: https://github.com/ethereum/go-ethereum/blob/v1.10.23/build/ci.go#L218
  tags = ["urfave_cli_no_docs"];

  meta = with lib; {
    homepage = "https://github.com/manifoldfinance/geth-sealer";
    description = "Geth Sealer implementation";
    license = with licenses; [lgpl3Plus gpl3Plus];
  };
}
