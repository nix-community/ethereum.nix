{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "geth-sealer";
  version = "geth-sealer-v1.11.4";

  src = fetchFromGitHub {
    owner = "manifoldfinance";
    repo = "geth-sealer";
    rev = "${version}";
    sha256 = "sha256-qM/5pDBXtT0koKlcLKn+3Bu/RQllHoCpv58L3oSTDzg=";
  };

  vendorSha256 = "sha256-ngOYJMcnh+vSFKuI904rjCUlpO8SyL7BsGCewVv26wU=";

  ldflags = ["-s" "-w"];

  doCheck = false;

  subPackages = ["cmd/geth"];

  # Following upstream: https://github.com/ethereum/go-ethereum/blob/v1.10.23/build/ci.go#L218
  tags = ["urfave_cli_no_docs"];

  meta = with lib; {
    homepage = "https://github.com/manifoldfinance/geth-sealer";
    description = "Geth Sealer implementation";
    license = with licenses; [lgpl3Plus gpl3Plus];
    platforms = ["x86_64-linux"];
  };
}
