{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "builder";
  version = "1.13.11.4844.dev3";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-jSN+DoO2pQC6Oj3oZ9av8d46SxxVGRGqwCHI4TJF3Os=";
  };

  vendorHash = "sha256-hJi904EZiX6Kc+KbcrbW7iss/nrZWSyuasDis/flRSg=";

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
