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
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "ssvlabs";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-xA2F4vsX/qXupRrpyZI82HGUlqpHzYTnCCOfXz6iEek=";
  };

  # Module cache keeps non-Go files, e.g. the prebuilt libhashtree.a of
  # pk910/hashtree-bindings that `go mod vendor` would drop.
  proxyVendor = true;
  vendorHash = "sha256-r+E+8uh8rGu1dX5PJLd2y7ip3na+ZOkAt6tZQW6FB14=";

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
    changelog = "https://github.com/ssvlabs/ssv/releases";
    license = lib.licenses.gpl3Only;
    mainProgram = "ssvnode";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
