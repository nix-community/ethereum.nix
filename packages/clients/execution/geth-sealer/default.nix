{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "geth-sealer";
  version = "geth-sealer-v1.12.0";

  src = fetchFromGitHub {
    owner = "manifoldfinance";
    repo = "geth-sealer";
    rev = "${version}";
    hash = "sha256-0Ym06RshDzn6+DEoBkjAAlvkWkMKSWcKF0xVR2KJWX8=";
  };

  vendorHash = "sha256-k5MbOiJDvWFnaAPViNRHeqFa64XPZ3ImkkvkmTTscNA=";

  ldflags = ["-s" "-w"];

  doCheck = false;

  subPackages = ["cmd/geth"];

  # Following upstream: https://github.com/ethereum/go-ethereum/blob/v1.10.23/build/ci.go#L218
  tags = ["urfave_cli_no_docs"];

  meta = with lib; {
    description = "Geth Sealer implementation";
    homepage = "https://github.com/manifoldfinance/geth-sealer";
    license = with licenses; [lgpl3Plus gpl3Plus];
    mainProgram = "geth";
    platforms = ["x86_64-linux"];
  };
}
