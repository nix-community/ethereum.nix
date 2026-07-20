{
  fetchFromGitHub,
  lib,
  libffi,
  libxml2,
  llvmPackages_22,
  m4,
  ncurses,
  nix-update-script,
  perl,
  rustPlatform,
  zlib,
}:
rustPlatform.buildRustPackage rec {
  pname = "reth";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-SR9fnlQ3z/+SvVYfkCVXbbabq6WauyM7FOqRj8Ig0oU=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse HEAD > "$out/COMMIT"
      rm -rf "$out/.git"
    '';
  };
  preBuild = ''
    export VERGEN_GIT_SHA=$(cat COMMIT)
    # .git is stripped in postFetch, so vergen-git2 can't derive these; supply
    # them as overrides for a clean tagged-release build (reth-node-core's
    # build script reads all three).
    export VERGEN_GIT_DIRTY=false
    export VERGEN_GIT_DESCRIBE=v${version}
  '';

  # reth's default features enable "jit" (the revmc EVM compiler), which builds
  # against LLVM via llvm-sys. llvm-sys 221.x targets LLVM 22.
  env.LLVM_SYS_221_PREFIX = "${lib.getDev llvmPackages_22.llvm}";

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "discv5-0.10.4" = "sha256-hfgBA/Nf77/et/SVeUz9RALAREXp66/CgjuwNcusRJA=";
      "revmc-0.1.0" = "sha256-aCMlJaDD/23dmRc87Iw0enpXC+BUCfeM+6Nv3TLJxJU=";
    };
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    perl # required for building sha3-asm
    m4 # required for building gmp-mpfr-sys (bundled GMP, pulled in via the gmp feature)
    llvmPackages_22.llvm.dev # revmc-llvm's build script runs llvm-config from PATH
  ];

  # Needed to link llvm-sys against LLVM (revmc/jit feature).
  buildInputs = [
    libffi
    libxml2
    ncurses
    zlib
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
