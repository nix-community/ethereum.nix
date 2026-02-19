{
  brotli,
  buildGoModule,
  callPackage,
  cmake,
  rust-cbindgen,
  fetchFromGitHub,
  fetchYarnDeps,
  fetchNpmDeps,
  fixup-yarn-lock,
  foundry,
  go-ethereum,
  lib,
  nodejs,
  rustPlatform,
  stdenv,
  wabt,
  yarn,
}:
let
  version = "3.9.5";

  # Pre-patched solc binaries
  solc = callPackage ./solc.nix { };
  inherit (solc)
    solc_0_7_6
    solc_0_8_9
    solc_0_8_17
    solc_0_8_24
    hardhatCompilerList
    ;

  src = fetchFromGitHub {
    owner = "OffchainLabs";
    repo = "nitro";
    rev = "v${version}";
    hash = "sha256-ZXYUTgqvzzt+9heM/Zs3j+qO9Trtxc4HBYvIQ3alzRU=";
    fetchSubmodules = true;
  };

  contractsYarnDeps = fetchYarnDeps {
    yarnLock = "${src}/contracts/yarn.lock";
    hash = "sha256-uSb9gstEumxUj0gF0Swwyz3aJU0NXmcXaAM44VPIXLs=";
  };

  contractsLegacyYarnDeps = fetchYarnDeps {
    yarnLock = "${src}/contracts-legacy/yarn.lock";
    hash = "sha256-oATGOUaNQP60dF5+IB+UUbWiqZxgvg5R4ngODhMR3L4=";
  };

  safeSmartAccountNpmDeps = fetchNpmDeps {
    src = "${src}/safe-smart-account";
    hash = "sha256-9yo/DKeZ/TLqSeK1pwni6h1+eqFnM0UfrItT7IRSxwU=";
  };

  # Build brotli with static libraries (nitro expects libbrotlienc-static.a, etc.)
  brotliStatic = stdenv.mkDerivation {
    pname = "brotli-static";
    inherit (brotli) version;
    inherit (brotli) src;

    nativeBuildInputs = [ cmake ];

    cmakeFlags = [
      "-DBUILD_SHARED_LIBS=ON"
      "-DBROTLI_BUILD_FOR_PACKAGE=ON"
      "-DBROTLI_BUILD_TOOLS=OFF"
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib $out/include
      cp libbrotlicommon-static.a $out/lib/
      cp libbrotlidec-static.a $out/lib/
      cp libbrotlienc-static.a $out/lib/
      cp -r ../c/include/brotli $out/include/
      runHook postInstall
    '';
  };

  # Build the forward tool that generates WAT files
  forwardTool = rustPlatform.buildRustPackage {
    pname = "nitro-forward-tool";
    inherit version src;

    sourceRoot = "source/arbitrator/wasm-libraries";

    cargoLock = {
      lockFile = "${src}/arbitrator/wasm-libraries/Cargo.lock";
    };

    # Remove the .cargo/config.toml that enables build-std for WASM targets
    # The forward crate is a native binary, not a WASM library
    postPatch = ''
      rm -f .cargo/config.toml
    '';

    buildPhase = ''
      runHook preBuild
      cargo build --release -p forward
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp target/release/forward $out/bin/
      runHook postInstall
    '';

    doCheck = false;
  };

  # Build WASM machine files needed by the prover
  wasmMachines = stdenv.mkDerivation {
    pname = "nitro-wasm-machines";
    inherit version;

    dontUnpack = true;

    nativeBuildInputs = [ wabt ];

    buildPhase = ''
      runHook preBuild

      # Generate WAT files using the forward tool
      ${forwardTool}/bin/forward --path forward_stub.wat --stub
      ${forwardTool}/bin/forward --path forward.wat

      # Convert WAT to WASM
      wat2wasm forward_stub.wat -o forward_stub.wasm
      wat2wasm forward.wat -o forward.wasm

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/machines/latest
      cp forward_stub.wasm $out/machines/latest/
      cp forward.wasm $out/machines/latest/

      runHook postInstall
    '';
  };

  # Build Rust arbitrator components (header + library)
  arbitrator = rustPlatform.buildRustPackage {
    pname = "nitro-arbitrator";
    inherit version src;

    # Build from repo root to access target/ directory
    cargoRoot = "arbitrator";

    cargoLock = {
      lockFile = "${src}/arbitrator/Cargo.lock";
      allowBuiltinFetchGit = true;
    };

    nativeBuildInputs = [
      rust-cbindgen
      stdenv.cc
    ];

    buildInputs = [
      brotliStatic
    ];

    # Set up WASM machines and brotli in postPatch while source is still writable
    postPatch = ''
      # Copy WASM machine files needed by prover (include_bytes!)
      # The path is ../../../target/machines/latest/ relative to prover/src/machine.rs
      # From repo root, that resolves to target/machines/latest/
      mkdir -p target/machines/latest
      cp ${wasmMachines}/machines/latest/* target/machines/latest/

      # Set up brotli static libraries in target/lib/ where brotli/build.rs looks
      mkdir -p target/lib
      ln -sf ${brotliStatic}/lib/libbrotlienc-static.a target/lib/
      ln -sf ${brotliStatic}/lib/libbrotlidec-static.a target/lib/
      ln -sf ${brotliStatic}/lib/libbrotlicommon-static.a target/lib/
    '';

    # Add library search paths via RUSTFLAGS
    RUSTFLAGS = "-L ${brotliStatic}/lib";

    # Build the stylus library
    buildPhase = ''
      runHook preBuild

      cd arbitrator

      # Build the stylus library
      cargo build --release --lib -p stylus

      # Generate the C header using cbindgen
      mkdir -p $TMPDIR/include
      cd stylus
      cbindgen --config cbindgen.toml --crate stylus --output $TMPDIR/include/arbitrator.h
      cd ../..

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib $out/include
      cp arbitrator/target/release/libstylus.a $out/lib/

      # Create probestack stub - Rust's libstylus.a references __rust_probestack
      # which isn't available when linking into non-Rust binaries (Go via CGO)
      $CC -c ${./probestack.S} -o probestack.o
      $AR rcs $out/lib/libprobestack.a probestack.o
      cp $TMPDIR/include/arbitrator.h $out/include/

      runHook postInstall
    '';

    doCheck = false;
  };

  # Patch to disable linting on forge builds (causes issues in sandbox)
  foundryLintPatch = ''
    [lint]
    lint_on_build = false
  '';

  # Build contracts artifacts
  contractArtifacts = stdenv.mkDerivation {
    pname = "nitro-contract-artifacts";
    inherit version src;

    nativeBuildInputs = [
      fixup-yarn-lock
      nodejs
      yarn
      foundry
    ];

    FOUNDRY_OFFLINE = "true";

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR
      export XDG_CACHE_HOME=$TMPDIR/.cache

      # Set up Hardhat compiler cache with pre-patched solc binaries
      mkdir -p $XDG_CACHE_HOME/hardhat-nodejs/compilers-v2/linux-amd64
      install -m 644 ${hardhatCompilerList} $XDG_CACHE_HOME/hardhat-nodejs/compilers-v2/linux-amd64/list.json
      install -m 755 ${solc_0_7_6} $XDG_CACHE_HOME/hardhat-nodejs/compilers-v2/linux-amd64/solc-linux-amd64-v0.7.6+commit.7338295f
      install -m 755 ${solc_0_8_9} $XDG_CACHE_HOME/hardhat-nodejs/compilers-v2/linux-amd64/solc-linux-amd64-v0.8.9+commit.e5eed63a
      install -m 755 ${solc_0_8_17} $XDG_CACHE_HOME/hardhat-nodejs/compilers-v2/linux-amd64/solc-linux-amd64-v0.8.17+commit.8df45f5f
      install -m 755 ${solc_0_8_24} $XDG_CACHE_HOME/hardhat-nodejs/compilers-v2/linux-amd64/solc-linux-amd64-v0.8.24+commit.e11b9ed9

      # Set up Foundry's SVM cache
      mkdir -p $HOME/.svm/0.8.24
      install -m 755 ${solc_0_8_24} $HOME/.svm/0.8.24/solc-0.8.24
      export FOUNDRY_SOLC="$HOME/.svm/0.8.24/solc-0.8.24"

      patchShebangs .

      # Build contracts
      cd contracts
      fixup-yarn-lock yarn.lock
      yarn config --offline set yarn-offline-mirror ${contractsYarnDeps}
      yarn install --offline --frozen-lockfile --ignore-scripts --no-progress
      patchShebangs node_modules
      yarn build
      printf '%s' ${lib.escapeShellArg foundryLintPatch} >> foundry.toml
      FOUNDRY_PROFILE=yul forge build --skip '*.sol'
      cd ..

      # Build contracts-legacy
      cd contracts-legacy
      fixup-yarn-lock yarn.lock
      yarn config --offline set yarn-offline-mirror ${contractsLegacyYarnDeps}
      yarn install --offline --frozen-lockfile --ignore-scripts --no-progress
      patchShebangs node_modules
      yarn build
      printf '%s' ${lib.escapeShellArg foundryLintPatch} >> foundry.toml
      FOUNDRY_PROFILE=yul forge build --skip '*.sol'
      cd ..

      # Build contracts-local with forge
      # contracts-local depends on ../contracts/src via @nitro-contracts remapping
      cd contracts-local
      printf '%s' ${lib.escapeShellArg foundryLintPatch} >> foundry.toml
      # Build main src contracts (outputs to out/src per foundry.toml default profile)
      forge build --offline --skip '*.yul' --skip 'src/mocks/*' --skip test
      # Build precompiles to separate output directory (gen.go expects out/precompiles)
      forge build src/precompiles --out out/precompiles --offline
      # Build gas-dimensions contracts (skip tests that need forge-std)
      if [ -d gas-dimensions ]; then
        FOUNDRY_PROFILE=gas-dimensions forge build --offline --skip test
        FOUNDRY_PROFILE=gas-dimensions-yul forge build --offline --skip test
      fi
      cd ..

      # Build safe-smart-account contracts with npm/hardhat
      cd safe-smart-account
      export npm_config_cache=${safeSmartAccountNpmDeps}
      npm ci --offline --ignore-scripts
      patchShebangs node_modules
      npm run build
      cd ..

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      # Copy contract build artifacts needed for solgen
      cp -r contracts/build $out/contracts-build
      cp -r contracts/out $out/contracts-out
      cp -r contracts-legacy/build $out/contracts-legacy-build
      cp -r contracts-local/out $out/contracts-local-out
      cp -r safe-smart-account/build $out/safe-smart-account-build
      # Optional artifacts that may not exist
      [ -d contracts/node_modules/@offchainlabs ] && cp -r contracts/node_modules/@offchainlabs $out/contracts-node-modules-offchainlabs
      [ -d contracts-legacy/out ] && cp -r contracts-legacy/out $out/contracts-legacy-out
      runHook postInstall
    '';
  };

  # Create source with stub solgen packages for Go module resolution
  srcWithStubs = stdenv.mkDerivation {
    pname = "nitro-source-with-stubs";
    inherit version src;

    buildPhase = ''
      runHook preBuild
      # Create stub Go packages for all expected solgen modules
      for pkg in bridgegen chaingen challengeV2gen challenge_legacy_gen contractsgen \
                 express_lane_auctiongen gas_dimensionsgen localgen mocksgen \
                 node_interfacegen ospgen precompilesgen rollupgen rollup_legacy_gen \
                 stategen stylusgen testgen test_helpersgen upgrade_executorgen yulgen \
                 assertionStakingPoolgen bridge_legacy_gen chain_legacy_gen \
                 express_lane_auction_legacy_gen libraries_legacy_gen librariesgen \
                 mocks_legacy_gen node_interface_legacy_gen osp_legacy_gen \
                 state_legacy_gen test_helpers_legacy_gen; do
        mkdir -p solgen/go/$pkg
        echo "package $pkg" > solgen/go/$pkg/$pkg.go
      done
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r . $out
      runHook postInstall
    '';
  };
in
buildGoModule {
  pname = "nitro";
  inherit version;
  # Use srcWithStubs so Go can resolve solgen packages during module validation
  src = srcWithStubs;

  vendorHash = "sha256-SIgtCPdicOtVrVbim+kuCQPgvFvpqqKM8qmwaXo0PTk=";
  proxyVendor = true;

  nativeBuildInputs = [
    go-ethereum # for abigen
  ];

  # CGO needs the arbitrator library and header
  # Also link probestack stub to provide __rust_probestack symbol
  CGO_CFLAGS = "-I${arbitrator}/include";
  CGO_LDFLAGS = "-L${arbitrator}/lib -lstylus -lprobestack";

  # Copy contract artifacts
  postPatch = ''
    # Link contract artifacts from the pre-built derivation
    mkdir -p contracts/build contracts/out contracts-legacy/build contracts-local/out safe-smart-account/build
    cp -r ${contractArtifacts}/contracts-build/* contracts/build/
    cp -r ${contractArtifacts}/contracts-out/* contracts/out/
    cp -r ${contractArtifacts}/contracts-legacy-build/* contracts-legacy/build/
    cp -r ${contractArtifacts}/contracts-local-out/* contracts-local/out/
    cp -r ${contractArtifacts}/safe-smart-account-build/* safe-smart-account/build/

    # Optional artifacts
    if [ -d ${contractArtifacts}/contracts-node-modules-offchainlabs ]; then
      mkdir -p contracts/node_modules/@offchainlabs
      cp -r ${contractArtifacts}/contracts-node-modules-offchainlabs/* contracts/node_modules/@offchainlabs/
    fi
    if [ -d ${contractArtifacts}/contracts-legacy-out ]; then
      mkdir -p contracts-legacy/out
      cp -r ${contractArtifacts}/contracts-legacy-out/* contracts-legacy/out/
    fi

    # Copy arbitrator header and library to expected locations
    # (CGO directives in the code reference target/include and target/lib)
    mkdir -p target/include target/lib
    cp ${arbitrator}/include/arbitrator.h target/include/
    cp ${arbitrator}/lib/libstylus.a target/lib/
  '';

  # Generate Go bindings in preBuild
  preBuild = ''
    export HOME=$TMPDIR

    # Remove stub directories - they might be read-only from srcWithStubs
    rm -rf solgen/go
    mkdir -p solgen/go

    # Patch gen.go to use cwd instead of runtime.Caller
    sed -i 's|"runtime"|_ "runtime"|' solgen/gen.go
    sed -i 's|_, filename, _, ok := runtime.Caller(0)|filename := "solgen/gen.go"|' solgen/gen.go
    sed -i 's|if !ok {|if false {|' solgen/gen.go

    # Generate Go bindings from contract ABIs
    go run solgen/gen.go
  '';

  # Override buildPhase to use -mod=mod for generated packages
  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR

    # Tell Go to not use GOPROXY for local packages
    export GOPRIVATE="github.com/offchainlabs/nitro/*"
    export GONOPROXY="github.com/offchainlabs/nitro/*"
    export GONOSUMDB="github.com/offchainlabs/nitro/*"

    # Build with -mod=mod to allow local generated packages
    for pkg in cmd/nitro cmd/relay; do
      echo "Building $pkg"
      go build -mod=mod -o $GOPATH/bin/$(basename $pkg) -ldflags "-s -w" ./$pkg
    done

    runHook postBuild
  '';

  doCheck = false;

  passthru = {
    category = "Arbitrum";
    skipAutoUpdate = true;
  };

  meta = with lib; {
    description = "Arbitrum Nitro node implementation for Ethereum Layer 2";
    homepage = "https://github.com/OffchainLabs/nitro";
    license = licenses.bsl11;
    mainProgram = "nitro";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
