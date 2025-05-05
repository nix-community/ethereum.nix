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
}:
stdenv.mkDerivation (finalAttrs: rec {
  pname = "besu";
  version = "25.4.1";

  src = fetchurl {
    url = "https://github.com/hyperledger/${pname}/releases/download/${version}/${pname}-${version}.tar.gz";
    hash = "sha256-EiPJ0AybrHOIzvp2mnOH68Z+l91JiXD7yLiULLwNfv0=";
  };

  buildInputs = lib.optionals stdenv.isLinux [jemalloc];
  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin
    cp -r bin $out/
    mkdir -p $out/lib
    cp -r lib $out/
    wrapProgram $out/bin/${pname} --set JAVA_HOME "${jre}" --suffix ${
      if stdenv.isDarwin
      then "DYLD_LIBRARY_PATH"
      else "LD_LIBRARY_PATH"
    } : ${lib.makeLibraryPath buildInputs}
  '';

  passthru.tests = {
    updateScript = nix-update-script {};

    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      version = "v${version}";
    };
    jemalloc =
      runCommand "${pname}-test-jemalloc"
      {
        nativeBuildInputs = [finalAttrs.finalPackage];
        meta.platforms = with lib.platforms; linux;
      } ''
        # Expect to find this string in the output, ignore other failures.
        (besu 2>&1 || true) | grep -q "# jemalloc: ${jemalloc.version}"
        mkdir $out
      '';
  };

  meta = with lib; {
    description = "Besu is an Apache 2.0 licensed, MainNet compatible, Ethereum client written in Java";
    homepage = "https://github.com/hyperledger/besu";
    license = licenses.asl20;
    mainProgram = "besu";
    platforms = ["aarch64-darwin" "x86_64-linux"];
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
})
