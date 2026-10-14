{
  lib,
  stdenv,
  fetchPnpmDeps,
  pnpm_11,
  pnpmConfigHook,
  autoPatchelfHook,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "solidity-language-server";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "NomicFoundation";
    repo = "hardhat-vscode";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IHKYIIkP+iyX0NiyEwrlYcQ4IwhIPp2rS9KRdtMixUA=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-Brl3UG/rZKSskhW3IUU1pj5/G2EDzZUJsuVYapweZ80=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_11
    pnpmConfigHook
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];
  pnpmInstallFlags = [ "--ignore-scripts" ];

  # Release telemetry credentials are private; build with empty values.
  env = {
    SOLIDITY_GA_SECRET = "";
    SOLIDITY_GOOGLE_TRACKING_ID = "";
    SOLIDITY_SENTRY_DSN = "";
  };
  postPatch = ''
    substituteInPlace scripts/bundle/utils/env.ts \
      --replace-fail 'value === undefined || value === ""' 'value === undefined'
  '';

  buildPhase = ''
    runHook preBuild
    pnpm --filter @nomicfoundation/solidity-language-server run bundle
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm config set --location=project inject-workspace-packages true
    pnpm --filter @nomicfoundation/solidity-language-server deploy \
      --prod --offline --ignore-scripts $out/lib/solidity-language-server

    makeWrapper ${lib.getExe nodejs} $out/bin/nomicfoundation-solidity-language-server \
      --add-flags $out/lib/solidity-language-server/out/index.js

    runHook postInstall
  '';

  preFixup = ''
    stripExclude+=("*.js" "*.ts" "*.map" "*.json" "*.md")
  '';

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Solidity language server by Nomic Foundation";
    longDescription = ''
      The Solidity language server from the Hardhat VSCode extension.
      Provides language support for Solidity including syntax highlighting,
      code completion, error checking, and intelligent code analysis.
    '';
    homepage = "https://github.com/NomicFoundation/hardhat-vscode";
    changelog = "https://github.com/NomicFoundation/hardhat-vscode/releases";
    license = lib.licenses.mit;
    mainProgram = "nomicfoundation-solidity-language-server";
    inherit (nodejs.meta) platforms;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
