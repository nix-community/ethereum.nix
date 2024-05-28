{
  fetchFromGitHub,
  lib,
  stdenv,
  lsb-release,
  which,
  cmake,
  pkgs,
  writeShellScriptBin,
  buildFlags ? ["nimbus_beacon_node" "nimbus_validator_client"],
}: let
  nim1 = pkgs.nim-unwrapped-1.overrideAttrs rec {
    version = "1.6.18";
    src = pkgs.fetchurl {
      url = "https://nim-lang.org/download/nim-${version}.tar.xz";
      hash = "sha256-UCQaxyIpG6ljdT8EWqo1h7c8GqKK4pxXPBWluKYCoss=";
    };
  };
in
  stdenv.mkDerivation rec {
    pname = "nimbus-eth2";
    version = "24.5.1";

    src = fetchFromGitHub {
      owner = "status-im";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-FSX26iMKUGa5zteL0UfhlXlqtl9AqVWja3NiQbYHrMM=";
      fetchSubmodules = true;
    };

    fakeGit = writeShellScriptBin "git" "echo ${version}";

    # Dunno why we need `lsb-release`, looks like for nim itself
    # without `which` it can't find gcc
    nativeBuildInputs = [fakeGit lsb-release nim1 which cmake];
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
