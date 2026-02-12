{
  bls_1_86,
  buildGoModule,
  fetchFromGitHub,
  lib,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "ssv-dkg";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "ssvlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-RsiYd00W5TBQmPzFCDKkzxEG+Yk+MDgMNcSRXoCa0tY=";
  };

  vendorHash = "sha256-MGIW+3Prti6vNWIrY6mbImMbaaEXi/OJnRRJpwM0m98=";

  buildInputs = [
    bls_1_86
    mcl
  ];

  subPackages = [ "cmd/ssv-dkg" ];

  ldflags = [ "-X main.Version=v${version}" ];

  passthru = {
    category = "SSV";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "The ssv-dkg tool enable operators to participate in ceremonies to generate distributed validator keys for Ethereum stakers.";
    homepage = "https://github.com/ssvlabs/ssv-dkg";
    license = with licenses; [ gpl3Plus ];
    mainProgram = "ssv-dkg";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
