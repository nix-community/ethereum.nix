{
  bls_1_86,
  buildGoModule,
  fetchFromGitHub,
  lib,
  mcl,
  nix-update-script,
  openssl,
}:
buildGoModule rec {
  pname = "ssv";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "ssvlabs";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-bK6NkTDBj8hGFn1ZTOzknPqX2GsCmVY4fnzwRPP6WS8=";
  };

  vendorHash = "sha256-fbkhy0S53Dy+I8t9X8jR8Fyi5upGnj9OmdtsbzslzoA=";

  buildInputs = [
    bls_1_86
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

  subPackages = [ "cmd/ssvnode" ];

  passthru = {
    category = "SSV";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/ssvlabs/ssv";
    license = lib.licenses.gpl3Only;
    mainProgram = "ssvnode";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
