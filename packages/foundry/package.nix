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
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "foundry-rs";
    repo = "foundry";
    tag = "v${version}";
    hash = "sha256-pS0V7AbSVowKXWfmk4TM9HyEVO1GL+FCZgdmpCfGcmM=";
  };

  cargoHash = "sha256-Ka751S1YhUQJCJYqD8bgjSm9IZPaBNg50DNDhmROQzs=";

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
