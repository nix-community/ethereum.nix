{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "builder";
  version = "1.13.2.4844.dev6+4d161de";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-TJObvNEsY1woaFPJ7B/0fUdvBVMmokdaHNqtbjh0yYs=";
  };

  vendorHash = "sha256-sx7SdaGnpPK65r/P/Yi9RKMAE6SI1hQGPhLF2GV+/t8=";

  buildInputs = [blst];

  subPackages = ["cmd/geth"];

  ldflags = ["-s" "-w"];

  meta = {
    description = "Flashbots mev-boost block builder";
    homepage = "https://github.com/flashbots/builder";
    mainProgram = "geth";
    platforms = ["x86_64-linux"];
  };
}
