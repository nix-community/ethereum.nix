{
  darwin,
  fetchFromGitHub,
  installShellFiles,
  lib,
  libusb1,
  perl,
  pkg-config,
  rustPlatform,
  stdenv,
  solc,
  svm-lists,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  pname = "foundry";
  version = "1.8.5";

  src = fetchFromGitHub {
    owner = "foundry-rs";
    repo = "foundry";
    tag = "v${version}";
    hash = "sha256-9z0Mz2oTxDt3AeJm8wrSmNRgKhds5TD57nVEFsZH0y4=";
  };

  cargoHash = "sha256-gy/XDPN2Jxqw7TQsXo2YY8WKxm0n+g9tmsLhfQl977k=";

  nativeBuildInputs = [
    pkg-config
    perl # required for building sha3-asm
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ darwin.DarwinTools ];

  buildInputs = [ solc ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ libusb1 ];

  env = {
    # Make svm-rs use local release list rather than fetching from non-reproducible URL.
    SVM_RELEASES_LIST_JSON = "${svm-lists}/list.json";
    VERGEN_GIT_SHA = "VERGEN_IDEMPOTENT_OUTPUT";
  };

  postInstall =
    let
      binsWithCompletions = [
        "anvil"
        "cast"
        "forge"
      ];
    in
    ''
      ${lib.concatMapStringsSep "\n" (bin: ''
        installShellCompletion --cmd ${bin} \
          --bash <($out/bin/${bin} completions bash) \
          --fish <($out/bin/${bin} completions fish) \
          --zsh <($out/bin/${bin} completions zsh)
      '') binsWithCompletions}
    '';

  # Tests are run upstream, and many perform I/O
  # incompatible with the nix build sandbox.
  doCheck = false;

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/forge";
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru = {
    category = "Development Tools";
  };

  meta = with lib; {
    mainProgram = "forge";
    description = "A portable, modular toolkit for Ethereum application development written in Rust.";
    homepage = "https://github.com/foundry-rs/foundry";
    changelog = "https://github.com/foundry-rs/foundry/releases";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [ mitchmindtree ];
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
