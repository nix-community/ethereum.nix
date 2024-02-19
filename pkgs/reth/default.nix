{
  darwin,
  fetchFromGitHub,
  lib,
  rustPlatform,
  stdenv,
}:
rustPlatform.buildRustPackage rec {
  pname = "reth";
  version = "0.1.0-alpha.18";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-XL78PIMo2Dy2VpEYsMohmirL717+U1kPlLGjSp0/gdc=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "alloy-genesis-0.1.0" = "sha256-4vFLWK2SeIMz22p33NrFLYXl6pG1+afpYLws1uMtIb4=";
      "discv5-0.3.1" = "sha256-Z/Yl/K6UKmXQ4e0anAJZffV9PmWdBg/ROnNBrB8dABE=";
      "revm-inspectors-0.1.0" = "sha256-qBOHfWJfDH2Ua93t6GZm1rQuxnkelVmEzA4R9lulW+Q=";
    };
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  # Some tests fail due to I/O that is unfriendly with nix sandbox.
  checkFlags = [
    "--skip=builder::tests::block_number_node_config_test"
    "--skip=builder::tests::launch_multiple_nodes"
    "--skip=builder::tests::rpc_handles_none_without_http"
    "--skip=cli::tests::override_trusted_setup_file"
    "--skip=cli::tests::parse_env_filter_directives"
  ];

  meta = with lib; {
    description = "Modular, contributor-friendly and blazing-fast implementation of the Ethereum protocol, in Rust";
    homepage = "https://github.com/paradigmxyz/reth";
    license = with licenses; [mit asl20];
    mainProgram = "reth";
    # `x86_64-darwin` seems to have issues with jemalloc, but these are fine.
    platforms = ["aarch64-darwin" "aarch64-linux" "x86_64-linux"];
  };
}
