{
  fetchFromGitHub,
  fetchPnpmDeps,
  foundry,
  svm-lists,
  lib,
  makeWrapper,
  nix-update-script,
  nodejs,
  pnpm,
  pnpmConfigHook,
  solc,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "alto";
  version = "0.0.19";

  src = fetchFromGitHub {
    owner = "pimlicolabs";
    repo = "alto";
    rev = "@pimlico/alto@${version}";
    hash = "sha256-Wn8rBwkOgz00CwQ10IrfwoJ3p6BIXqHyfT9wWhVREVU=";
    fetchSubmodules = true;
  };

  # The upstream pnpm-lock.yaml is lockfileVersion 6.0 (pnpm 8), which the
  # pnpm shipped by nixpkgs (pnpm 11) refuses to read. Replace it with a
  # regenerated lockfileVersion 9.0 lockfile for the same dependency set.
  postPatch = ''
    cp ${./pnpm-lock.yaml} pnpm-lock.yaml
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      postPatch
      ;
    inherit pnpm;
    hash = "sha256-pEPIctOHKwYv2DSIuuv9Ln0OKRWguuoP4qTB3AufyoI=";
    fetcherVersion = 4;
  };

  nativeBuildInputs = [
    foundry
    makeWrapper
    nodejs
    pnpm
    pnpmConfigHook
    solc
  ];

  SVM_RELEASES_LIST_JSON = "${svm-lists}/list.json";

  buildPhase = ''
    runHook preBuild

    # Export SVM_RELEASES_LIST_JSON for forge to use
    export SVM_RELEASES_LIST_JSON="$SVM_RELEASES_LIST_JSON"

    # Build Solidity contracts manually using solc from nixpkgs
    # instead of relying on svm to download solc
    mkdir -p src/contracts

    # Build PimlicoSimulations
    forge build --root contracts --evm-version london \
      --out ../src/contracts/ src/PimlicoSimulations.sol \
      --use ${solc}/bin/solc || true

    # Build EntryPoint contracts using the available solc
    for contract in \
      "src/v06/EntryPointFilterOpsOverride.sol" \
      "src/v07/EntryPointFilterOpsOverride.sol" \
      "src/v08/EntryPointFilterOpsOverride.sol" \
      "src/v09/EntryPointFilterOpsOverride.sol" \
      "src/v06/EntryPointGasEstimationOverride.sol" \
      "src/v07/EntryPointSimulations.sol" \
      "src/v08/EntryPointSimulations.sol" \
      "src/v09/EntryPointSimulations.sol"
    do
      if [ -f "contracts/$contract" ]; then
        forge build --root contracts \
          --out ../src/contracts/ "$contract" \
          --use ${solc}/bin/solc || true
      fi
    done

    # Build the TypeScript
    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/alto
    cp -r . $out/lib/alto

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/alto \
      --add-flags "$out/lib/alto/src/esm/cli/alto.js"

    runHook postInstall
  '';

  passthru = {
    category = "Account Abstraction";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "A performant, reliable, and type-safe ERC-4337 Bundler written in TypeScript";
    homepage = "https://github.com/pimlicolabs/alto";
    license = licenses.gpl3Only;
    mainProgram = "alto";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
