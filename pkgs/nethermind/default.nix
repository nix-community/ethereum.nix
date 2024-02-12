{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  lib,
  lz4,
  rocksdb,
  snappy,
  stdenv,
  zstd,
  writeShellScriptBin,
}: let
  self = buildDotnetModule rec {
    pname = "nethermind";
    version = "1.19.3";

    src = fetchFromGitHub {
      owner = "NethermindEth";
      repo = pname;
      rev = version;
      hash = "sha256-vqcgBT7kSyrgRl2hLehbCjsQ/AC4+a3LMOdAcmcNOFo=";
      fetchSubmodules = true;
    };

    buildInputs = [
      lz4
      snappy
      stdenv.cc.cc.lib
      zstd
    ];

    runtimeDeps = [
      rocksdb
      snappy
    ];

    patches = [
      ./001-Remove-Commit-Fallback.patch
    ];

    projectFile = "src/Nethermind/Nethermind.sln";
    nugetDeps = ./nuget-deps.nix;

    executables = [
      "Nethermind.Cli"
      "Nethermind.Runner"
    ];

    dotnet-sdk = dotnetCorePackages.sdk_7_0;
    dotnet-runtime = dotnetCorePackages.aspnetcore_7_0;

    passthru = {
      # buildDotnetModule's `fetch-deps` uses `writeShellScript` instead of writeShellScriptBin making nix run .#nethermind.fetch-deps command to fail
      # This alias solves that issue. On parent folder, we only need to run this command to produce a new nuget-deps.nix file with updated deps:
      # $ nix run .#nethermind.fetch-nethermind-deps $PRJ_ROOT/pkgs/nethermind/nuget-deps.nix
      fetch-nethermind-deps = writeShellScriptBin "fetch-nethermind-deps" ''${self.fetch-deps} $@'';
    };

    meta = {
      description = "Our flagship Ethereum client for Linux, Windows, and macOS—full and actively developed";
      homepage = "https://nethermind.io/nethermind-client";
      license = lib.licenses.gpl3;
      mainProgram = "Nethermind.Runner";
      platforms = ["x86_64-linux"];
    };
  };
in
  self
