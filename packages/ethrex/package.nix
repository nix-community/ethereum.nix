{
  aws-lc,
  fetchFromGitHub,
  fetchurl,
  lib,
  libgit2,
  nix-update-script,
  openssl,
  perl,
  pkg-config,
  rustPlatform,
  zlib,
}:
let
  pname = "ethrex";
  version = "32.0.0";

  # sp1-prover's build.rs downloads this verification-key map from S3 at build
  # time; the nix sandbox has no network. Fetch it as a fixed-output derivation
  # and drop it into the vendored crate's expected src/vk_map.bin (build.rs then
  # copies it after an SHA256 check instead of downloading). Hash is pinned in
  # sp1-prover-5.0.8/build.rs as SHA256_HASH.
  sp1VkMap = fetchurl {
    url = "https://sp1-circuits.s3.us-east-2.amazonaws.com/vk-map-v5.0.0";
    hash = "sha256-XnNfbkT1bp7ukeViYlJmOvzFJjKH0cWYA2ez+fkwoOg=";
  };

  src = fetchFromGitHub {
    owner = "lambdaclass";
    repo = "ethrex";
    rev = "v${version}";
    hash = "sha256-Dcpdav8sDId2BmlgPMKaKKacxQzz3+nfCghQDrEyb6Q=";
  };

  # Upstream's Cargo.lock no longer has name-version collisions between
  # crates.io and git sources (the old [patch.crates-io] workaround is gone);
  # we ship it as-is.
  patchCargo = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  # importCargoLock creates a flat vendor directory with symlinks keyed by
  # crate name-version. When two lockfile entries share the same name-version
  # but differ only in the git source URL (e.g. openvm from ?tag=v1.4.1 vs
  # bare), the second ln -s fails because the symlink target already exists.
  # Since both entries resolve to the same commit (same code), we use ln -sfT
  # to safely overwrite.
  vendorDir =
    (rustPlatform.importCargoLock {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "agg_mode_sdk-0.1.0" = "sha256-19sernICnubqIVIsdt9/oLxq0Ki+BBHA/Hl+yTg6oTw=";
        "lambdaworks-crypto-0.12.0" = "sha256-4vgW/O85zVLhhFrcZUwcPjavy/rRWB8LGTabAkPNrDw=";
        "openvm-1.4.1" = "sha256-alW8dZO7Lw3jQ/4W9DO19+1B/RA2PMc0GSOOnI8T9dY=";
        "openvm-kzg-0.2.0-alpha" = "sha256-nLk0cqKW1IVdWNKm86ZkdSBEt1+kRYeth3xlfI74x28=";
        "p3-field-0.1.0" = "sha256-KYPhsvXaoQxUM6JH9CpDrVGccOEITp05zbCECa+jOQg=";
        "zisk-circuit-1.1.0-alpha" = "sha256-H9hDB7r0SiiNm9NsamUb0bCmAe+XIMinRBZ5PelS/Do=";
      };
    }).overrideAttrs
      (old: {
        buildCommand =
          builtins.replaceStrings [ ''ln -s "$crate" $out/'' ] [ ''ln -sfT "$crate" $out/'' ]
            old.buildCommand;
      });
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoDeps = vendorDir;

  postPatch = patchCargo;

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    perl
  ];

  buildInputs = [
    aws-lc
    libgit2
    openssl
    zlib
  ];

  # vergen-git2 needs a .git directory; skip it in nix builds
  env.VERGEN_IDEMPOTENT = "1";

  # sp1-core-machine and sp1-recursion-core enable a `sys` feature by default
  # whose build.rs runs cbindgen, which spawns a nested `cargo metadata`. That
  # sub-invocation tries to fully resolve the crate's dependency graph
  # (including optional deps such as `rug`) against our feature-pruned vendor
  # dir and fails offline. These crates are designed to build without `sys`
  # (pure-Rust fallback; build.rs then emits an empty stub lib), and nothing in
  # the tree requests `sys` explicitly, so drop it from their defaults.
  preBuild = ''
    # nixpkgs' cargoSetupHook points JEMALLOC_OVERRIDE at a system jemalloc.
    # tikv-jemalloc-sys expects its own static, unprefixed jemalloc 5.3 build;
    # linking the shared nixpkgs one crashes at runtime (SIGSEGV in
    # libjemalloc.so), so let it build the vendored copy as before.
    unset JEMALLOC_OVERRIDE

    # sp1 6.x no longer has a `sys` feature, so only patch manifests that still
    # have it (the 5.x crates).
    for crate in sp1-core-machine sp1-recursion-core; do
      find "$NIX_BUILD_TOP" -maxdepth 3 -path "*/$crate-*/Cargo.toml" -print0 \
        | while IFS= read -r -d "" manifest; do
        if grep -qF 'default = ["sys"]' "$manifest"; then
          substituteInPlace "$manifest" \
            --replace-fail 'default = ["sys"]' 'default = []'
        fi
      done
    done

    # Provide sp1-prover's verification-key map so its build.rs skips the
    # network download (see sp1VkMap above).
    find "$NIX_BUILD_TOP" -maxdepth 2 -type d -name 'sp1-prover-*' -print0 \
      | while IFS= read -r -d "" crate; do
      mkdir -p "$crate/src"
      cp ${sp1VkMap} "$crate/src/vk_map.bin"
    done
  '';

  buildAndTestSubdir = "cmd/ethrex";

  # Enable L2 feature
  buildFeatures = [ "l2" ];

  auditable = false;

  doCheck = false;

  passthru = {
    category = "Execution Clients";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Modular and ZK-native Ethereum execution client written in Rust";
    homepage = "https://github.com/lambdaclass/ethrex";
    changelog = "https://github.com/lambdaclass/ethrex/releases";
    license = with licenses; [
      mit
      asl20
    ];
    mainProgram = "ethrex";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
