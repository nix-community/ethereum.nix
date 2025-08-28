{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "vouch";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-LdcIXagKeOxCZAY1odIf9+6y/X3l9vl/xtQZFjHkBEc=";
  };

  vendorHash = "sha256-cb5qHLy8ZfhlkbdE1/ceMQorpBDuQEauQ1ptWfJT6Tk=";

  runVend = true;

  buildInputs = [mcl bls];

  doCheck = false;

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "An Ethereum 2 multi-node validator client";
    homepage = "https://github.com/attestantio/vouch";
    mainProgram = "vouch";
    platforms = ["x86_64-linux"];
  };
}
