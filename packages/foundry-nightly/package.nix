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
}:
let
  # Nightly tag format: nightly-<commit-hash>
  # Update by running: nix-update --flake foundry-nightly --version branch=nightly
  nightlyTag = "nightly-128b8886bfd573cfe063d2ca9fd8daf6655e9289";
  nightlyDate = "2026-02-20";
in
rustPlatform.buildRustPackage rec {
  pname = "foundry-nightly";
  version = "nightly-${nightlyDate}";

  src = fetchFromGitHub {
    owner = "foundry-rs";
    repo = "foundry";
    rev = nightlyTag;
    hash = "sha256-n+WY8jhZcAIRLNmzhPcm7LojF/ju7+KP94Y5eEIz8b0=";
  };

  cargoHash = "sha256-K/im9SuORYafxh6TOzkWR/lGMxvVI/MXO5/0rPgfuJU=";

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ darwin.DarwinTools ];

  buildInputs = [ solc ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ libusb1 ];

  env = {
    # Make svm-rs use local release list rather than fetching from non-reproducible URL.
    SVM_RELEASES_LIST_JSON = "${svm-lists}/list.json";
    # Provide git info for vergen since .git directory is not available
    VERGEN_GIT_SHA = builtins.elemAt (lib.strings.splitString "-" nightlyTag) 1;
    VERGEN_IDEMPOTENT = "1";
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

  # Nightly version string format differs from stable
  doInstallCheck = false;

  passthru = {
    category = "Development Tools";
  };

  meta = with lib; {
    description = "Nightly build of Foundry - A portable, modular toolkit for Ethereum application development written in Rust.";
    homepage = "https://github.com/foundry-rs/foundry";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [ mitchmindtree ];
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
      "x86_64-darwin"
    ];
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
