{
  buildDotnetModule,
  dotnet-sdk_6,
  dotnetCorePackages,
  fetchFromGitHub,
  lib,
  lz4,
  rocksdb,
  snappy,
  stdenv,
  zstd,
}:
buildDotnetModule rec {
  pname = "nethermind";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "NethermindEth";
    repo = pname;
    rev = version;
    sha256 = "sha256-oBWCsXDWjw9PzukZVa4sdwIXEHUVqeHe30QAswYkq4w=";
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

  dotnet-sdk = dotnetCorePackages.sdk_6_0;
  dotnet-test-sdk = dotnet-sdk_6;
  dotnet-runtime = dotnetCorePackages.aspnetcore_6_0;

  meta = with lib; {
    description = "Our flagship Ethereum client for Linux, Windows, and macOS—full and actively developed";
    homepage = "https://nethermind.io/nethermind-client";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
