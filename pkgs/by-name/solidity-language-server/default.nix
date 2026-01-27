{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
  nix-update-script,
}:
buildNpmPackage rec {
  pname = "solidity-language-server";
  version = "0.8.27";

  src = fetchFromGitHub {
    owner = "NomicFoundation";
    repo = "hardhat-vscode";
    rev = "v${version}";
    hash = "sha256-Qmqsm9Gv1vmdU6v37VGZhTiJLVgW/anxQwP/oSyZkoM=";
  };

  npmDepsHash = "sha256-STgqGYzChXv/4vpBTboGhSAnN1ml2nDLHsu53bmBw4M=";

  makeCacheWritable = true;
  npmFlags = ["--ignore-scripts"];

  nativeBuildInputs = [makeWrapper];

  buildPhase = ''
    runHook preBuild
    npx tsc -b ./server/tsconfig.build.json
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/solidity-language-server/node_modules

    cp -r server/out $out/lib/solidity-language-server/

    for item in node_modules/*; do
      if [ -d "$item" ] && [ ! -L "$item" ]; then
        cp -rL "$item" "$out/lib/solidity-language-server/node_modules/"
      fi
    done

    makeWrapper ${lib.getExe' nodejs "node"} $out/bin/nomicfoundation-solidity-language-server \
      --add-flags $out/lib/solidity-language-server/out/index.js

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Solidity language server by Nomic Foundation";
    longDescription = ''
      The Solidity language server from the Hardhat VSCode extension.
      Provides language support for Solidity including syntax highlighting,
      code completion, error checking, and intelligent code analysis.
    '';
    homepage = "https://github.com/NomicFoundation/hardhat-vscode";
    license = lib.licenses.mit;
    mainProgram = "nomicfoundation-solidity-language-server";
    inherit (nodejs.meta) platforms;
  };
}
