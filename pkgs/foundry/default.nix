{
  lib,
  stdenv,
  darwin,
  fetchFromGitHub,
  installShellFiles,
  libusb1,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "foundry";
  version = "nightly-${builtins.substring 0 7 src.rev}";

  src = fetchFromGitHub {
    owner = "foundry-rs";
    repo = "foundry";
    rev = "8a08a3a92b0c842db2f254983cc3bd179300ad46";
    hash = "sha256-djEWWltp+5DErOsADmcF/NlCNslAfDMMhLmFSm0HbBM=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  env = {
    # Make svm-rs use local release list rather than fetching from non-reproducible URL.
    # Run the `update-svm-lists.sh` script to update these lists.
    SVM_RELEASES_LIST_JSON =
      if stdenv.isDarwin
      then "${./svm-lists/macosx-amd64.json}"
      else "${./svm-lists/linux-amd64.json}";
  };

  nativeBuildInputs =
    [
      installShellFiles
      pkg-config
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.DarwinTools
    ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
    libusb1
  ];

  postInstall = let
    binsWithCompletions = ["anvil" "cast" "forge"];
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

  meta = with lib; {
    description = "A portable, modular toolkit for Ethereum application development written in Rust.";
    homepage = "https://github.com/foundry-rs/foundry";
    license = with licenses; [asl20 mit];
    maintainers = with maintainers; [mitchmindtree];
    # For now, solc binaries are only built for x86_64.
    # Track darwin-aarch64 here:
    # https://github.com/ethereum/solidity/issues/12291
    platforms = ["x86_64-linux" "x86_64-darwin"];
  };
}
