{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  openssl,
}:
buildGoModule rec {
  pname = "ssv";
  version = "2.0.0-unstable.2";

  src = fetchFromGitHub {
    owner = "ssvlabs";
    repo = "${pname}";
    rev = "cdce10d1f95866a9e13003934fc3771d22a8aba4";
    hash = "sha256-1VyGA9nIDIJvL4zqHIAuxlY8FWywZ8ycYm06zCCUP3M=";
  };

  vendorHash = "sha256-cVSbOxyul87/y0lp0x9INw76XzHFTBOv9BjQTs2bvPU=";

  buildInputs = [bls mcl];

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

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/ssvlabs/ssv";
    platforms = ["x86_64-linux"];
    mainProgram = "ssvnode";
  };
}
