{
  darwin,
  fetchFromGitHub,
  lib,
  rustPlatform,
  stdenv,
}:
rustPlatform.buildRustPackage rec {
  pname = "reth";
  version = "0.2.0-beta.6";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ZcQ29AwlTU6rDiknlJbOo8JubXQOJg1UVMSlRb1l8Yk=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "alloy-consensus-0.1.0" = "sha256-2TZeQo0d+Yp0M46VNx3OZoyDT4F31cLdOpl1tk3syfg=";
      "discv5-0.4.1" = "sha256-agrluN1C9/pS/IMFTVlPOuYl3ZuklnTYb46duVvTPio=";
      "revm-inspectors-0.1.0" = "sha256-ZRlYNEHD+wewlttUcMuEoTYg9Hn89JVAr7+hIeMBXog=";
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
