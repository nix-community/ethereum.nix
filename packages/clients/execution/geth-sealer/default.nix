{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "geth-sealer";
  version = "geth-sealer-v1.11.5";

  src = fetchFromGitHub {
    owner = "manifoldfinance";
    repo = "geth-sealer";
    rev = "${version}";
    hash = "sha256-aMIYxEfdOMhwN9pJEiqNPDLhEbFyFey6nq0spc+A1VE=";
  };

  vendorSha256 = "sha256-Y1srOcXZ4rQ0QIQx4LdYzYG6goGk6oO30C+OW+s81z4=";

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
