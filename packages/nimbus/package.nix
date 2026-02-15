# NOTE adapted from https://github.com/status-im/nimbus-eth2/tree/stable/nix by ethereum.nix
{
  darwin,
  which,
  stdenv,
  lib,
  writeScriptBin,
  callPackage,
  fetchFromGitHub,
}:
let
  version = "26.2.0";
  src = fetchFromGitHub {
    owner = "status-im";
    repo = "nimbus-eth2";
    rev = "v${version}";
    hash = "sha256-Q3uTdKGcsWJPvAZ5iqHAzz2u5Hvsr0g0f092y7hwZ9c=";
    fetchSubmodules = true;
  };
  targets = [
    "nimbus_beacon_node"
    "nimbus_validator_client"
    "gnosis-build"
    "gnosis-vc-build"
  ];
  stableSystems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  # Options: 0,1,2
  verbosity = 1;
  # Perform 2-stage bootstrap instead of 3-stage to save time.
  quickAndDirty = true;
in

stdenv.mkDerivation rec {
  pname = "nimbus-eth2";
  inherit src version;

  # Fix for Nim compiler calling 'git rev-parse' and 'lsb_release'.
  nativeBuildInputs =
    let
      fakeGit = writeScriptBin "git" "echo ${version}";
      fakeLsbRelease = writeScriptBin "lsb_release" "echo nix";
    in
    [
      fakeGit
      fakeLsbRelease
      which
    ]
    ++ lib.optionals stdenv.isDarwin [ darwin.cctools ];

  enableParallelBuilding = true;

  # Disable CPU optmizations that make binary not portable.
  NIMFLAGS = "-d:disableMarchNative";
  # Avoid Nim cache permission errors.
  XDG_CACHE_HOME = "/tmp";

  makeFlags = targets ++ [
    "V=${toString verbosity}"
    # TODO: Compile Nim in a separate derivation to save time.
    "QUICK_AND_DIRTY_COMPILER=${if quickAndDirty then "1" else "0"}"
    "QUICK_AND_DIRTY_NIMBLE=${if quickAndDirty then "1" else "0"}"
  ];

  # Generate the nimbus-build-system.paths file.
  configurePhase = ''
    patchShebangs scripts vendor/nimbus-build-system > /dev/null
    make nimbus-build-system-paths
  '';

  # Avoid nimbus-build-system invoking `git clone` to build Nim.
  preBuild = ''
    pushd vendor/nimbus-build-system/vendor/Nim
    mkdir dist
    cp -r --no-preserve=mode ${callPackage ./nimble.nix { }}    dist/nimble
    cp -r --no-preserve=mode ${callPackage ./checksums.nix { }} dist/checksums
    cp -r --no-preserve=mode ${callPackage ./csources.nix { }}  csources_v2
    popd
  '';

  installPhase = ''
    mkdir -p $out/bin
    rm -f build/generate_makefile
    cp build/* $out/bin
  '';

  meta = with lib; {
    homepage = "https://nimbus.guide/";
    downloadPage = "https://github.com/status-im/nimbus-eth2/releases";
    changelog = "https://github.com/status-im/nimbus-eth2/blob/stable/CHANGELOG.md";
    description = "Nimbus is a lightweight client for the Ethereum consensus layer";
    longDescription = ''
      Nimbus is an extremely efficient consensus layer client implementation.
      While it's optimised for embedded systems and resource-restricted devices --
      including Raspberry Pis, its low resource usage also makes it an excellent choice
      for any server or desktop (where it simply takes up fewer resources).
    '';
    license = with licenses; [
      asl20
      mit
    ];
    mainProgram = "nimbus_beacon_node";
    platforms = stableSystems;
  };
}
