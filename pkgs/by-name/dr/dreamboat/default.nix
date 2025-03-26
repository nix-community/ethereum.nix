{
  blst,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "dreamboat";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "blocknative";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-jbUJekXC2YzR4ZmnAAYjNNrae90aXALCAw0pf1bfTiw=";
  };

  vendorHash = "sha256-1eA7tO9xxUVlcWLxBoBTmmXwVsact7N5fND9NCrvReg=";

  buildInputs = [blst];

  subPackages = ["cmd/dreamboat"];

  ldflags = ["-s" "-w"];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "An Ethereum 2.0 Relay for proposer-builder separation (PBS) with MEV-boost";
    homepage = "https://github.com/blocknative/dreamboat";
    mainProgram = "dreamboat";
    platforms = ["x86_64-linux"];
  };
}
