{
  lib,
  nodejs_20,
  stdenv,
  fetchFromGitHub,
  nodePackages,
  cacert,
  corepack_20,
  python3,
}: let
  name = "lodestar";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "ChainSafe";
    repo = name;
    rev = "refs/tags/v${version}";
    hash = "sha256-oYfmdlCmx7YqBV7G+IJeHnXzLpyfcLU8t8iz0os0cvo=";
  };

  yarnDeps = stdenv.mkDerivation {
    pname = "${name}-yarn-deps";
    inherit version src;

    nativeBuildInputs = [
      python3
      cacert
      corepack_20
      nodePackages.node-gyp
      nodejs_20
    ];

    preBuild = ''
      export HOME=$(mktemp -d)

      yarn set version 4.0.1

      yarn config set enableTelemetry false
      yarn config set enableProgressBars false
    '';

    buildPhase = ''
      runHook preBuild
      yarn install
    '';

    installPhase = ''
      mkdir $out
      mv node_modules $out
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-qLrRRAarQsIHpLSIndBiJmFL++zhRLPAzkv3Q88Rw2Y=";

    meta.platforms = ["x86_64-linux"];
  };
in
  stdenv.mkDerivation rec {
    pname = name;
    inherit version src;

    buildInputs = [
      yarnDeps
      corepack_20
    ];

    preBuild = ''
      export HOME=($mktemp -d)

      yarn set version 4.0.1

      yarn config set enableImmutableCache true
      yarn config set enableInlineBuilds true
      yarn config set enableInmutableInstalls true
      yarn config set enableOfflineMode true
      yarn config set enableProgressBars false
      yarn config set enableTelemetry false
      yarn config set cacheFolder ${yarnDeps}

      yarn install
    '';

    buildPhase = ''
      runHook preBuild

      yarn run build

      patchShebangs bin/*
    '';

    installPhase = ''
      mkdir -p $out/bin
    '';

    passthru = {
      inherit yarnDeps;
    };

    meta = with lib; {
      description = "TypeScript Implementation of Ethereum Consensus";
      homepage = "https://lodestar.chainsafe.io/";
      changelog = "https://github.com/ChainSafe/lodestar/releases/tag/v${version}";
      license = licenses.bsl11;
      mainProgram = name;
      platforms = ["x86_64-linux"];
      maintainers = with maintainers; [aldoborrero];
    };
  }
