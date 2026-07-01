{
  bls_1_86,
  buildGoModule,
  fetchFromGitHub,
  lib,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "charon";
  version = "1.10.3";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    hash = "sha256-VIFhi1Se78nwF4yJz6eujTg2r9r8bjheqLxvRCZlpVw=";
  };

  vendorHash = "sha256-CLDYcTDjUjQjmR5/3sDbgt+E1jz9dIx23XqrcLDp92s=";

  buildInputs = [
    bls_1_86
    mcl
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];

  passthru = {
    category = "Validators";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Charon (pronounced 'kharon') is a Proof of Stake Ethereum Distributed Validator Client";
    homepage = "https://github.com/ObolNetwork/charon";
    license = lib.licenses.bsl11;
    mainProgram = "charon";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
