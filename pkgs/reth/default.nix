{
  darwin,
  fetchFromGitHub,
  lib,
  rustPlatform,
  stdenv,
  pkgs,
  crane,
  cargo-nextest,
}: let
  craneLib = (crane.mkLib pkgs).overrideToolchain (p: p.rust-bin.stable.latest.default);
  commonArgs = rec {
    pname = "reth";
    version = "1.0.1";

    src = fetchFromGitHub {
      owner = "paradigmxyz";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-GqBNyPeXIN7q2m3SkhP4BUYXyEQYlkP0JH/pKgEvf7k=";
    };
    strictDeps = true;

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
    ];

    nativeBuildInputs = [
      # Doesn't actually depend on rust version, so using this hook from nixpkgs is fine
      rustPlatform.bindgenHook
    ];
  };
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
  craneLib.buildPackage (commonArgs
    // {
      inherit cargoArtifacts;

      nativeBuildInputs =
        commonArgs.nativeBuildInputs
        ++ [
          cargo-nextest
        ];

      # `x86_64-darwin` seems to have issues with jemalloc
      cargoExtraArgs =
        "--no-default-features"
        + (
          if stdenv.system != "x86_64-darwin"
          then " --features jemalloc"
          else ""
        );

      cargoTestCommand = "cargo nextest run";
      cargoTestExtraArgs = builtins.concatStringsSep " " [
        "--hide-progress-bar"
        "--workspace"
        "--exclude ef-tests"
        "-E"
        # Only run unit tests (`!kind(test)`) and skip several tests which can't run within the nix sandbox
        "'!kind(test) - test(cli::tests::parse_env_filter_directives) - test(tests::test_exex) - test(auth_layer::tests::test_jwt_layer)'"
      ];

      # https://crane.dev/faq/rebuilds-bindgen.html
      NIX_OUTPATH_USED_AS_RANDOM_SEED = "aaaaaaaaaa";

      meta = with lib; {
        description = "Modular, contributor-friendly and blazing-fast implementation of the Ethereum protocol, in Rust";
        homepage = "https://github.com/paradigmxyz/reth";
        license = with licenses; [mit asl20];
        mainProgram = "reth";
        platforms = ["aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux"];
      };
    })
