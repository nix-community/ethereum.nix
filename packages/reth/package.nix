{
  fetchFromGitHub,
  lib,
  stdenv,
  libffi,
  libxml2,
  llvmPackages_23,
  m4,
  ncurses,
  nix-update-script,
  openssl,
  perl,
  rustPlatform,
  versionCheckHook,
  zlib,
}:
rustPlatform.buildRustPackage rec {
  pname = "reth";
  version = "2.11.0";

  src = fetchFromGitHub {
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-DZL2bDxCvzYIC3cHQbT9loo0tX/UYLjaTPwXNalVj5k=";
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

  preCheck = ''
    # add a dummy certificate so reqwest::Client can init
    # taken from nixpkgs/pkgs/development/tools/build-managers/gradle/update-deps.nix
    pushd "$(mktemp -d)" >/dev/null
    ${openssl}/bin/openssl genrsa -out ca.key 2048
    ${openssl}/bin/openssl req -x509 -new -nodes -key ca.key -sha256 -days 1 -out ca.cer -subj "/C=AL/ST=a/L=a/O=a/OU=a/CN=example.org"
    export SSL_CERT_FILE=$(pwd)/ca.cer
    popd >/dev/null
  '';

  # reth's default features enable "jit" (the evm2 EVM JIT), which builds
  # against LLVM via llvm-sys. llvm-sys 231.x targets LLVM 23.
  env.LLVM_SYS_231_PREFIX = "${lib.getDev llvmPackages_23.llvm}";

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "bedrock-assertions-0.1.0" = "sha256-mYq11aX8QUOrWBfypD+xZGeWg1a9vGjRiUokjCMovWQ=";
      "evm2-0.1.0" = "sha256-T848lt3vrDVWq8JoMtv2JMkIyryB18+0r0cEC2KSDAQ=";
      "reth-codecs-0.8.2" = "sha256-xUGM6YD5A8aWrTD0+hATmL4aeMJ4nQGuS/FLbucTV2U=";
    };
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    perl # required for building sha3-asm
    m4 # required for building gmp-mpfr-sys (bundled GMP, pulled in via the gmp feature)
    llvmPackages_23.llvm.dev # llvm-sys needs llvm-config (LLVM 23) on PATH
  ];

  # Needed to link llvm-sys against LLVM (evm2 jit feature).
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
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Tests added in 2.6.0 that fail on Darwin with PermissionDenied
    "--skip=download"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Execution Clients";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Modular, contributor-friendly and blazing-fast implementation of the Ethereum protocol, in Rust";
    homepage = "https://github.com/paradigmxyz/reth";
    changelog = "https://github.com/paradigmxyz/reth/releases";
    license = with licenses; [
      mit
      asl20
    ];
    mainProgram = "reth";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
