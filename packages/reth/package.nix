{
  fetchFromGitHub,
  lib,
  nix-update-script,
  perl,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "reth";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-BaStAg29MeJkJf9w/eGvq8LIU9nla/Q/oSpVF0EG1hg=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    perl # required for building sha3-asm
  ];

  # Some tests fail due to I/O that is unfriendly with nix sandbox.
  checkFlags = [
    "--skip=builder::tests::block_number_node_config_test"
    "--skip=builder::tests::launch_multiple_nodes"
    "--skip=builder::tests::rpc_handles_none_without_http"
    "--skip=cli::tests::override_trusted_setup_file"
    "--skip=cli::tests::parse_env_filter_directives"
    # Tests added in 1.11.0 that fail in sandbox
    "--skip=config_default_valid_toml"
    "--skip=dev_node_eth_syncing"
    "--skip=dev_node_send_tx_and_mine"
    "--skip=dump_genesis_mainnet_valid_json"
    "--skip=dump_genesis_sepolia_valid_json"
  ];

  passthru = {
    category = "Execution Clients";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Modular, contributor-friendly and blazing-fast implementation of the Ethereum protocol, in Rust";
    homepage = "https://github.com/paradigmxyz/reth";
    license = with licenses; [
      mit
      asl20
    ];
    mainProgram = "reth";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
