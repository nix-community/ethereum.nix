{
  fetchFromGitHub,
  lib,
  libgit2,
  nix-update-script,
  perl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zlib,
  zstd,
}:
rustPlatform.buildRustPackage rec {
  pname = "ethlambda";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "lambdaclass";
    repo = "ethlambda";
    tag = "v${version}";
    hash = "sha256-uyR80VkNeP2P+fD1O0dYMMht3Nz2E0T6LquaLmepxuY=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse HEAD > "$out/COMMIT"
      rm -rf "$out/.git"
    '';
  };

  cargoHash = "sha256-QnxtbedDE3hrSMCP3cBFHnTCTNNT9xkEs7XF+Beg4AY=";

  # .git is stripped in postFetch, so vergen-git2 cannot read these. The
  # client version embeds the channel (branch, or "stable" for releases) and
  # the commit.
  preBuild = ''
    # nixpkgs' cargoSetupHook points JEMALLOC_OVERRIDE at a system jemalloc;
    # tikv-jemalloc-sys must build its vendored copy instead.
    unset JEMALLOC_OVERRIDE
    export VERGEN_GIT_SHA=$(cut -c1-8 COMMIT)
    export VERGEN_GIT_BRANCH=stable
  '';

  cargoBuildFlags = [
    "--bin"
    "ethlambda"
  ];

  nativeBuildInputs = [
    perl # sha3-asm
    pkg-config
    rustPlatform.bindgenHook # librocksdb-sys
  ];

  # nixpkgs cargoSetupHook forces these *-sys crates onto system libraries.
  buildInputs = [
    libgit2
    zlib
    zstd
  ];

  # Upstream's test profile needs release-grade optimisation and fixtures; the
  # version check below exercises the built binary instead.
  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Consensus Clients";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Minimalist and fast Ethereum consensus client by LambdaClass, for the Beacon and Lean chains";
    homepage = "https://github.com/lambdaclass/ethlambda";
    changelog = "https://github.com/lambdaclass/ethlambda/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ selfuryon ];
    mainProgram = "ethlambda";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
