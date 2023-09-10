{
  fetchFromGitHub,
  lib,
  stdenv,
  nim,
  lsb-release,
  which,
  cmake,
  writeShellScriptBin,
  buildFlags ? ["nimbus_beacon_node"],
}:
stdenv.mkDerivation rec {
  pname = "nimbus-eth2";
  version = "23.9.0";

  src = fetchFromGitHub {
    owner = "status-im";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-aTuFyaOnXhfBbOvbDth4ECIrdekVdz/eEMcHXOxzX5w=";
    fetchSubmodules = true;
  };

  fakeGit = writeShellScriptBin "git" "echo ${version}";

  # Dunno why we need `lsb-release`, looks like for nim itself
  # without `which` it can't find gcc
  nativeBuildInputs = [fakeGit lsb-release nim which cmake];
  enableParallelBuilding = true;

  NIMFLAGS = "-d:disableMarchNative -d:release";

  makeFlags = ["USE_SYSTEM_NIM=1"];
  inherit buildFlags;
  dontConfigure = true;

  preBuild = ''
    patchShebangs scripts vendor/nimbus-build-system/scripts
    make nimbus-build-system-paths
  '';

  installPhase = ''
    mkdir -p $out/bin
    rm -f build/generate_makefile
    cp build/* $out/bin
  '';

  meta = {
    description = "Nim implementation of the Ethereum Beacon Chain";
    homepage = "https://github.com/status-im/nimbus-eth2";
    license = lib.licenses.asl20;
    mainProgram = "nimbus_beacon_node";
    platforms = ["x86_64-linux"];
  };
}
