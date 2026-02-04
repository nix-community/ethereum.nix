{
  fetchurl,
  jemalloc,
  jre,
  lib,
  makeWrapper,
  nix-update-script,
  runCommand,
  stdenv,
  testers,
  gawk,
}:
stdenv.mkDerivation (finalAttrs: rec {
  pname = "besu";
  version = "26.1.0";

  src = fetchurl {
    url = "https://github.com/hyperledger/${pname}/releases/download/${version}/${pname}-${version}.tar.gz";
    hash = "sha256-3mNWvy2556aNw945GGTcNzoEQPUfv2141j0eIFCRJI4=";
  };

  buildInputs = lib.optionals stdenv.isLinux [ jemalloc ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r bin $out/
    mkdir -p $out/lib
    cp -r lib $out/
    wrapProgram $out/bin/${pname} --set JAVA_HOME "${jre}" --suffix ${
      if stdenv.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH"
    } : ${lib.makeLibraryPath buildInputs} ${
      if stdenv.isLinux then (" --prefix PATH : " + lib.makeBinPath [ gawk ]) else ""
    }
  '';
  passthru = {
    category = "Execution Clients";

    updateScript = nix-update-script { };

    tests = {
      version = testers.testVersion {
        package = finalAttrs.finalPackage;
        version = "v${version}";
      };
      jemalloc =
        runCommand "${pname}-test-jemalloc"
          {
            meta.platforms = with lib.platforms; linux;
          }
          ''
            # Verify jemalloc is in the LD_LIBRARY_PATH of the wrapper script.
            # We can't run besu in the sandbox as it requires /sys access.
            grep -q "jemalloc" "${finalAttrs.finalPackage}/bin/besu"
            mkdir $out
          '';
    };
  };

  meta = with lib; {
    description = "Besu is an Apache 2.0 licensed, MainNet compatible, Ethereum client written in Java";
    homepage = "https://github.com/hyperledger/besu";
    license = licenses.asl20;
    mainProgram = "besu";
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
  };
})
