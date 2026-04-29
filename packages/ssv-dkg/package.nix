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
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "ssvlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-q1r6Ul+fz5j1rzfJVdC8T3q3z2BhI1ODu3j6iQWv7Oc=";
  };

  vendorHash = "sha256-vyqkYU61LTax30zRLvugcqJaDP1Rn9Vgzq8gt5pInQ8=";

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
