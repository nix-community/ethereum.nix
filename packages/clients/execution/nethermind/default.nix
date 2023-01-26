{
  buildDotnetModule,
  dotnet-sdk_7,
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
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "NethermindEth";
    repo = pname;
    rev = version;
    sha256 = "sha256-JYU+3gI06hkB4bew6dzeD2B7ZXkyKMtgz9qk/za+cqs=";
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

  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  dotnet-test-sdk = dotnet-sdk_7;
  dotnet-runtime = dotnetCorePackages.aspnetcore_7_0;

  meta = with lib; {
    description = "Our flagship Ethereum client for Linux, Windows, and macOS—full and actively developed";
    homepage = "https://nethermind.io/nethermind-client";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
