{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "builder";
  version = "1.11.5-0.2.3";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-ePWPKElg3Y+IzrgRQtWVhfrvLhTHK1rE3GspM/j5kxM=";
  };

  vendorHash = "sha256-PwsJjcgPXQuOtXDr4NjF7IEk+nrhDBfEnQQyyBFFSjE=";

  buildInputs = [blst];

  subPackages = ["cmd/geth"];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Flashbots mev-boost block builder";
    homepage = "https://github.com/flashbots/builder";
    mainProgram = "geth";
    platforms = ["x86_64-linux"];
  };
}
