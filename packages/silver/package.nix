{
  aws-lc,
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
  pname = "silver";
  version = "0.1.0-alpha.16";

  src = fetchFromGitHub {
    owner = "gattaca-com";
    repo = "silver";
    tag = "v${version}";
    hash = "sha256-oMlZH0AluLWH9v6Lv/6XOse4rd4+QOPM31aJWsdex1E=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short=7 HEAD > "$out/COMMIT"
      rm -rf "$out/.git"
    '';
  };

  cargoHash = "sha256-E4ChHwe+iL++U+TydNTKkydLETeF+sQrw/XVUPKX9JA=";

  # .git is stripped in postFetch; the build script embeds this commit in the
  # build info instead of reading it from git.
  preBuild = ''
    export SILVER_BUILD_COMMIT=$(cat COMMIT)
  '';

  # Same binaries and profile as upstream's Docker image.
  buildType = "release-prod";
  cargoBuildFlags = [
    "--bin"
    "silver"
    "--bin"
    "silver_surfer"
  ];

  nativeBuildInputs = [
    perl # sha3-asm
    pkg-config
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
