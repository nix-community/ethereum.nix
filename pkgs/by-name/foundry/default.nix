{
  darwin,
  fetchFromGitHub,
  installShellFiles,
  lib,
  libusb1,
  nix-update-script,
  pkg-config,
  rustPlatform,
  stdenv,
  solc,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  pname = "foundry";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "foundry-rs";
    repo = "foundry";
    tag = "v${version}";
    hash = "sha256-SrkFfc9+cb3nDqEOj3gRkQq9aKOSfk3s7a3EGka5ACw=";
  };

  cargoHash = "sha256-PoPfuMNeK6ArZddBd0lsR2r8UrvRieqkxYZ8jCCxw5o=";

  nativeBuildInputs =
    [
      pkg-config
      installShellFiles
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [darwin.DarwinTools];

  buildInputs = [solc] ++ lib.optionals stdenv.hostPlatform.isDarwin [libusb1];

  env = {
    # Make svm-rs use local release list rather than fetching from non-reproducible URL.
    # Run the `update-svm-lists.sh` script to update these lists.
    SVM_RELEASES_LIST_JSON =
      if stdenv.isDarwin
      then "${./svm-lists/macosx-amd64.json}"
      else "${./svm-lists/linux-amd64.json}";
  };

  postInstall = let
    binsWithCompletions = [
      "anvil"
      "cast"
      "forge"
    ];
  in ''
    ${lib.concatMapStringsSep "\n" (bin: ''
        installShellCompletion --cmd ${bin} \
          --bash <($out/bin/${bin} completions bash) \
          --fish <($out/bin/${bin} completions fish) \
          --zsh <($out/bin/${bin} completions zsh)
      '')
      binsWithCompletions}
  '';

  # Tests are run upstream, and many perform I/O
  # incompatible with the nix build sandbox.
  doCheck = false;

  nativeInstallCheckInputs = [versionCheckHook];
  versionCheckProgram = "${placeholder "out"}/bin/forge";
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "A portable, modular toolkit for Ethereum application development written in Rust.";
    homepage = "https://github.com/foundry-rs/foundry";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [mitchmindtree];
    # TODO: Change this to `platforms = platforms.unix;` when this is resolved:
    # https://github.com/ethereum/solidity/issues/11351
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
      "x86_64-darwin"
    ];
  };
}
