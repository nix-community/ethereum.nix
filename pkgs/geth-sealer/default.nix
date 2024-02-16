{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "geth-sealer";
  version = "geth-sealer-v1.13.5";

  src = fetchFromGitHub {
    owner = "manifoldfinance";
    repo = "geth-sealer";
    rev = "${version}";
    hash = "sha256-UHIhEHDVaLTmJdvUFQxQi6f1v46+KQXTrivUEBVCSMA=";
  };

  vendorHash = "sha256-dOvpOCMxxmcAaticSLVlro1L4crAVJWyvgx/JZZ7buE=";

  ldflags = ["-s" "-w"];

  doCheck = false;

  subPackages = ["cmd/geth"];

  # Following upstream: https://github.com/ethereum/go-ethereum/blob/v1.10.23/build/ci.go#L218
  tags = ["urfave_cli_no_docs"];

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = with lib; {
    description = "Geth Sealer implementation";
    homepage = "https://github.com/manifoldfinance/geth-sealer";
    license = with licenses; [lgpl3Plus gpl3Plus];
    mainProgram = "geth";
    platforms = ["x86_64-linux"];
  };
}
