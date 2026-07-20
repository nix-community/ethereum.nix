{
  fetchFromGitHub,
  fetchurl,
  lib,
  nix-update-script,
  openssl,
  perl,
  pkg-config,
  rustPlatform,
}:
let
  pname = "ethrex";
  version = "21.0.0";

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
    hash = "sha256-FUPxbo96ikUP8qQnjSosN52TNixQFMkoFK/P7rOMY9w=";
  };

  # Upstream Cargo.lock has crates from both crates.io and git forks with the
  # same name-version (bls12_381, halo2curves-axiom, zkhash). We unify them
  # via [patch.crates-io]. It also has openvm crates from two git refs of the
  # same repo; we pin both to a single commit via `cargo update --precise` in
  # our shipped Cargo.lock.
  patchCargo = ''
    cat >> Cargo.toml <<'PATCH'

    [patch.crates-io]
    bls12_381 = { git = "https://github.com/lambdaclass/bls12_381", branch = "expose-affine-constructors" }
    halo2curves-axiom = { git = "https://github.com/axiom-crypto/halo2curves.git", tag = "v0.7.2" }
    zkhash = { git = "https://github.com/HorizenLabs/poseidon2.git", rev = "bb476b9" }
    PATCH

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
        "bls12_381-0.8.0" = "sha256-tpKF3wxog7eH1oDbpjoFjYibvH6u2kiR/H2Ysazqeok=";
        "circuit-0.16.1" = "sha256-4LG9R9CpsP4kLJ6Cvk8Afu7wGYjxTl1ZLIrgFPdTdAM=";
        "fields-0.16.1" = "sha256-iVBcuUgi8OEPbxQRHHVcSYlhHBcxbHS9F1Rx9Rr73Kg=";
        "halo2curves-axiom-0.7.2" = "sha256-tJtt6rAL70TNzVXjnci04X0oUK3duE7SklBIyBftd+I=";
        "lambdaworks-crypto-0.12.0" = "sha256-4vgW/O85zVLhhFrcZUwcPjavy/rRWB8LGTabAkPNrDw=";
        "openvm-1.4.1" = "sha256-alW8dZO7Lw3jQ/4W9DO19+1B/RA2PMc0GSOOnI8T9dY=";
        "openvm-1.5.0" = "sha256-j+xbsipH6fnFbn+cw1yQd5iJpKafTILns/O+ubseGYk=";
        "openvm-kzg-0.2.0-alpha" = "sha256-nLk0cqKW1IVdWNKm86ZkdSBEt1+kRYeth3xlfI74x28=";
        "openvm-cuda-backend-1.3.0" = "sha256-m+HK8varzuDnyc/E3p13I5tS5l6EjXS3Si7q/c0o5cw=";
        "openvm-stark-backend-1.2.1" = "sha256-l9x7beeeXGvz2i7f6cgxet5OiKzur1X3wdkIShxyQlk=";
        "p3-air-0.1.0" = "sha256-KYPhsvXaoQxUM6JH9CpDrVGccOEITp05zbCECa+jOQg=";
        "zkhash-0.2.0" = "sha256-SmfMuw6BKQxzKJyqWt29Gtpu8oHQLRXgf2kR8mZt6X0=";
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
    openssl
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
    for crate in sp1-core-machine sp1-recursion-core; do
      find "$NIX_BUILD_TOP" -maxdepth 3 -path "*/$crate-*/Cargo.toml" -print0 \
        | while IFS= read -r -d "" manifest; do
        substituteInPlace "$manifest" \
          --replace-fail 'default = ["sys"]' 'default = []'
      done
    done

    # Provide sp1-prover's verification-key map so its build.rs skips the
    # network download (see sp1VkMap above).
    find "$NIX_BUILD_TOP" -maxdepth 3 -type d -path "*/sp1-prover-*" -print0 \
      | while IFS= read -r -d "" crate; do
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
    license = with licenses; [
      mit
      asl20
    ];
    mainProgram = "ethrex";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
