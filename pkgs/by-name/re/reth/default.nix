{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "reth";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Z+ctKDds4Vo+P5yItz42k7u6uiINXHZvaZLU2c5Tfyo=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
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
    platforms = ["aarch64-linux" "x86_64-linux"];
  };
}
