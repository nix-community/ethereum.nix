{
  aws-lc,
  fetchFromGitHub,
  lib,
  libgit2,
  nix-update-script,
  perl,
  pkg-config,
  protobuf,
  rustPlatform,
  versionCheckHook,
  zlib,
  zstd,
}:
rustPlatform.buildRustPackage rec {
  pname = "silver";
  version = "0.1.0-alpha.21";

  src = fetchFromGitHub {
    owner = "gattaca-com";
    repo = "silver";
    tag = "v${version}";
    hash = "sha256-JAaqUhROHXB4bh1/65D6BnOIQYbIBRXrjrRXDVH1F+M=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short=7 HEAD > "$out/COMMIT"
      rm -rf "$out/.git"
    '';
  };

  cargoHash = "sha256-SuaScRU+BwJ1BU/AmtXju+3mnc/n5aGxfDxvq08ltfc=";

  # .git is stripped in postFetch; the build script embeds this commit in the
  # build info instead of reading it from git.
  preBuild = ''
    export SILVER_BUILD_COMMIT=$(cat COMMIT)

    # protobuf-build (raft-proto's build script) only accepts protoc 3.x and
    # otherwise falls back to a bundled binary that cannot run here. The
    # protoc from nixpkgs (>= 22) handles raft's proto files fine.
    find "$NIX_BUILD_TOP" -maxdepth 3 -type d -name 'protobuf-build-*' -print0 \
      | while IFS= read -r -d "" crate; do
      substituteInPlace "$crate/src/protobuf_impl.rs" \
        --replace-fail 'if major == 3 && minor >= 1 {' 'if major > 3 || (major == 3 && minor >= 1) {'
    done
  '';

  # Same binaries as upstream's Docker image. Its `release-prod` profile is
  # `release` plus panic = "abort"; nixpkgs' cargo hooks cannot take a profile
  # name with a dash (they export CARGO_PROFILE_<NAME>_STRIP), so build
  # `release` with that one override.
  env.CARGO_PROFILE_RELEASE_PANIC = "abort";
  cargoBuildFlags = [
    "--bin"
    "silver"
    "--bin"
    "silver_surfer"
  ];

  nativeBuildInputs = [
    perl # sha3-asm
    pkg-config
    protobuf # protoc for raft-proto
    rustPlatform.bindgenHook
  ];

  # nixpkgs cargoSetupHook forces these *-sys crates onto system libraries.
  buildInputs = [
    aws-lc
    libgit2
    zlib
    zstd
  ];

  # The workspace tests need fixtures and networking; the version check below
  # exercises the built binary instead.
  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Consensus Clients";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Ethereum consensus client by Gattaca";
    homepage = "https://github.com/gattaca-com/silver";
    changelog = "https://github.com/gattaca-com/silver/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ selfuryon ];
    mainProgram = "silver";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
