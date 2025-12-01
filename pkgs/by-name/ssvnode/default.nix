{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  nix-update-script,
  openssl,
}:
buildGoModule rec {
  pname = "ssv";
  version = "2.3.8";

  src = fetchFromGitHub {
    owner = "ssvlabs";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-ym70x6iTPZtiOOp2aA6tCrrWz+dHzmQrjnGooqZgpGk=";
  };

  vendorHash = "sha256-fryQJLT0ozH4tfzhkqPGtGjO2zebzk7bUSZyZdp51PQ=";

  buildInputs = [
    bls
    mcl
  ];

  ldflags = [
    "-X main.Commit=${src.rev}"
    "-X main.Version=v${version}"
  ];

  # Dynamic loading of openssl
  # See: https://github.com/ssvlabs/ssv/blob/v2.0.0-unstable.0/operator/keys/rsa_linux.go#L30
  postFixup = ''
    patchelf \
      --add-rpath ${openssl.out}/lib \
      $out/bin/ssvnode
  '';

  subPackages = ["cmd/ssvnode"];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/ssvlabs/ssv";
    platforms = ["x86_64-linux"];
    mainProgram = "ssvnode";
  };
}
