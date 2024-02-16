{
  blst,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "dreamboat";
  version = "0.4.20";

  src = fetchFromGitHub {
    owner = "blocknative";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-Hqsx4zP0KB3rXXC7aYk3G4qS9sQfCqXP5ODFAP1TLoE=";
  };

  vendorHash = "sha256-fjkBek1/AdBlm4plN0zPLLiqh3jHg8MA2FJs06SXkFQ=";

  buildInputs = [blst];

  subPackages = ["cmd/dreamboat"];

  ldflags = ["-s" "-w"];

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = {
    description = "An Ethereum 2.0 Relay for proposer-builder separation (PBS) with MEV-boost";
    homepage = "https://github.com/blocknative/dreamboat";
    mainProgram = "dreamboat";
    platforms = ["x86_64-linux"];
  };
}
