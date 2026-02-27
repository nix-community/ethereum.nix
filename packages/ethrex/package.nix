{
  fetchFromGitHub,
  lib,
  nix-update-script,
  openssl,
  perl,
  pkg-config,
  rustPlatform,
}:
let
  pname = "ethrex";
  version = "9.0.0";

  src = fetchFromGitHub {
    owner = "lambdaclass";
    repo = "ethrex";
    rev = "v${version}";
    hash = "sha256-gQIMAnGDJoLiP6TyJ4Y2kGyNMC2Kl3rxrb2oRBX170w=";
  };

  # Upstream Cargo.lock has crates from both crates.io and git forks with the
  # same name-version (bls12_381, halo2curves-axiom, zkhash). We unify them
  # via [patch.crates-io]. It also has openvm crates from two git refs of the
  # same repo; we pin both to a single commit via `cargo update --precise` in
  # our shipped Cargo.lock.
  patchCargo = ''
    cat >> Cargo.toml <<'PATCH'

    [patch.crates-io]
    bls12_381 = { git = "https://github.com/lambdaclass/bls12_381", branch = "expose-fp-struct" }
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
        "aligned-sdk-0.1.0" = "sha256-aBU5mgGoKHDG2OYL+qJGSk97hn2AirxQ3soaK9DShpQ=";
        "bls12_381-0.8.0" = "sha256-8/pXRA7hVAPeMKCZ+PRPfQfxqstw5Ob4MJNp85pv5WQ=";
        "halo2curves-axiom-0.7.2" = "sha256-tJtt6rAL70TNzVXjnci04X0oUK3duE7SklBIyBftd+I=";
        "lambdaworks-crypto-0.12.0" = "sha256-4vgW/O85zVLhhFrcZUwcPjavy/rRWB8LGTabAkPNrDw=";
        "lib-c-0.15.0" = "sha256-hzV4NedLnKV1JN497S7iiUq91NQltyx3M1W33SKWkeE=";
        "openvm-1.4.1" = "sha256-7f1MaOu/F0W5QyPZtz44h9IkAA94QLMrVOHzZa0yelk=";
        "openvm-cuda-backend-1.2.1" = "sha256-l9x7beeeXGvz2i7f6cgxet5OiKzur1X3wdkIShxyQlk=";
        "openvm-kzg-0.2.0-alpha" = "sha256-nLk0cqKW1IVdWNKm86ZkdSBEt1+kRYeth3xlfI74x28=";
        "p3-field-0.1.0" = "sha256-KYPhsvXaoQxUM6JH9CpDrVGccOEITp05zbCECa+jOQg=";
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
