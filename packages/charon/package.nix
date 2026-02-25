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
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    hash = "sha256-ovKw8Vbfg/q8tC03aYJ64I2rS9BHsadhVuzMCH1MXE8=";
  };

  vendorHash = "sha256-IgSPJtE692/QFOS2xp21FS+0b6PNS1+62pghQ2FtMPo=";

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
