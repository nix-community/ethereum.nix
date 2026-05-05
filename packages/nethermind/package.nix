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
}:
buildDotnetModule rec {
  pname = "nethermind";
  version = "1.37.2";

  src = fetchFromGitHub {
    owner = "NethermindEth";
    repo = pname;
    rev = version;
    hash = "sha256-EmfQVc5GDaJ6YYLDVUUIqtNpK8IMIu3brF9C7/Rbk2Q=";
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

  projectFile = [
    "src/Nethermind/Nethermind.Runner/Nethermind.Runner.csproj"
  ];
  nugetDeps = ./nuget-deps.json;

  executables = [
    "nethermind"
  ];

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;

  passthru = {
    category = "Execution Clients";
    updateScript = ./update.py;
  };

  meta = {
    description = "Our flagship Ethereum client for Linux, Windows, and macOS—full and actively developed";
    homepage = "https://nethermind.io/nethermind-client";
    license = lib.licenses.gpl3;
    mainProgram = "Nethermind.Runner";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
