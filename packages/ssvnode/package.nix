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
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "ssvlabs";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-HVFujURNN8k47Kx/s6ebG4mcKYE4DYsS7NbG6mCXnVI=";
  };

  # Module cache keeps non-Go files, e.g. the prebuilt libhashtree.a of
  # pk910/hashtree-bindings that `go mod vendor` would drop.
  proxyVendor = true;
  vendorHash = "sha256-kkZ3QKL4NGRbRjBKYYm7yeo71SScrD5kFqAUQOcJNMU=";

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
