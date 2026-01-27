{
  blst,
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "mev-boost-relay";
  version = "0.32.0";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-dLnoCVK/MZpEtZBIPnwJgCA151C5glOfTCS7Jvx48zw=";
  };

  vendorHash = "sha256-FbFpub4nVn7UFj4AdlmSI6YSfkd1C3NRPC2tGGOqb80=";

  buildInputs = [ blst ];

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  passthru = {
    category = "MEV";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "MEV-Boost Relay for Ethereum proposer/builder separation (PBS)";
    homepage = "https://github.com/flashbots/mev-boost-relay";
    license = lib.licenses.agpl3Only;
    mainProgram = "mev-boost-relay";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
