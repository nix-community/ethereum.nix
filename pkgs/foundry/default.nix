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
    rev = "0688b5ad19a637303c038d1a66aec62a73713e20";
    hash = "sha256-OIsUzJVNcb2nVCYU/BdGGGICEg9Cr9LXc8zzN2JSb8g=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "alloy-consensus-0.1.0" = "sha256-rHDLt0N6VIAlg2EKEdF0S2S8XqJebRlIB7owyGQ04aA=";
      "ethers-2.0.11" = "sha256-ySrCZOiqOcDVH5T7gbimK6Bu7A2OCcU64ZL1RfFPrBc=";
      "revm-3.5.0" = "sha256-gdDJq2ZyIkMhTgMNz45YJXnopF/xxt3CaSd/eYSDGcY=";
      "revm-inspectors-0.1.0" = "sha256-mH6On3cjKLT14S+5dxB1G5lcf5PBtz0KcusMxOtRRWA=";
    };
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
