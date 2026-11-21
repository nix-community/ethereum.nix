{
  aws-lc,
  darwin,
  fetchFromGitHub,
  fetchurl,
  installShellFiles,
  lib,
  libusb1,
  perl,
  pkg-config,
  rust-jemalloc-sys,
  rustPlatform,
  sqlite,
  stdenv,
  solc,
  svm-lists,
  versionCheckHook,
  zstd,
}:
let
  # tempo-chainspec (a git dependency) reads these from the tempo repository
  # root in its build.rs, but cargo vendoring keeps only the crate directory.
  # Keep the rev in sync with tempo-chainspec in foundry's Cargo.lock.
  tempoRev = "55a96bad10cb3e171f1b28dfd6e21bea957df0e4";
  tempoNetworkIdentities = {
    "mainnet-network-identity.json" = fetchurl {
      url = "https://raw.githubusercontent.com/tempoxyz/tempo/${tempoRev}/mainnet-network-identity.json";
      hash = "sha256-XZakmOuroaTfsx9N4yDDMjqktcqyCd7F9wW3HtxyWkU=";
    };
    "testnet-network-identity.json" = fetchurl {
      url = "https://raw.githubusercontent.com/tempoxyz/tempo/${tempoRev}/testnet-network-identity.json";
      hash = "sha256-wIVvzfPgpguSaTZjnLnFfGGaLrJQdlE+aNVn35x2KpU=";
    };
  };
in
rustPlatform.buildRustPackage rec {
  pname = "foundry";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "foundry-rs";
    repo = "foundry";
    tag = "v${version}";
    hash = "sha256-9k+78ednqFo8/rdGDOWqS8Y+eZ/6kxFd5Ojit/pjeJM=";
  };

  cargoHash = "sha256-LBhRrQ1N6ygZZ6hApX+WOtZmKypmO95fOThIo+tyZks=";

  nativeBuildInputs = [
    pkg-config
    perl # required for building sha3-asm
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ darwin.DarwinTools ];

  # nixpkgs cargoSetupHook forces *-sys crates onto system libraries.
  buildInputs = [
    aws-lc
    rust-jemalloc-sys
    solc
    sqlite
    zstd
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ libusb1 ];

  env = {
    # Make svm-rs use local release list rather than fetching from non-reproducible URL.
    SVM_RELEASES_LIST_JSON = "${svm-lists}/list.json";
    VERGEN_GIT_SHA = "VERGEN_IDEMPOTENT_OUTPUT";
  };

  # build.rs searches the crate's ancestors, so the vendored crate directory
  # itself works. ($cargoDepsCopy is already unset by preBuild.)
  preBuild = ''
    find "$NIX_BUILD_TOP" -maxdepth 3 -type d -name 'tempo-chainspec-*' -print0 \
      | while IFS= read -r -d "" crate; do
      ${lib.concatStrings (
        lib.mapAttrsToList (name: file: ''
          cp ${file} "$crate/${name}"
        '') tempoNetworkIdentities
      )}
    done
  '';

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
