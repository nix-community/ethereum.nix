{
  darwin,
  fetchFromGitHub,
  installShellFiles,
  lib,
  libusb1,
  pkg-config,
  rustPlatform,
  stdenv,
  solc,
  svm-lists,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  pname = "foundry";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "foundry-rs";
    repo = "foundry";
    tag = "v${version}";
    hash = "sha256-UCaBo4hMStmh79UiyYu7vEO7UtrvwJshe4PTMkqZV0w=";
  };

  cargoHash = "sha256-iAWUEVgOgn2Zw9fINxyH9Bynh+flzCY40YFGoVLgG8k=";

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ darwin.DarwinTools ];

  buildInputs = [ solc ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ libusb1 ];

  env = {
    # Make svm-rs use local release list rather than fetching from non-reproducible URL.
    SVM_RELEASES_LIST_JSON = "${svm-lists}/list.json";
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
    description = "A portable, modular toolkit for Ethereum application development written in Rust.";
    homepage = "https://github.com/foundry-rs/foundry";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [ mitchmindtree ];
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
