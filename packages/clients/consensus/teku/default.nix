{
  fetchurl,
  jre,
  lib,
  makeWrapper,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "teku";
  version = "22.12.0";

  src = fetchurl {
    url = "https://artifacts.consensys.net/public/${pname}/raw/names/${pname}.tar.gz/versions/${version}/${pname}-${version}.tar.gz";
    sha256 = "sha256-kgoHWUZdaV4v2SECPyBMRVMdH3OmnRQYzBbgEFOc27Q=";
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin
    cp -r bin $out/
    mkdir -p $out/lib
    cp -r lib $out/
    wrapProgram $out/bin/${pname} --set JAVA_HOME "${jre}"
  '';

  meta = with lib; {
    description = "Java Implementation of the Ethereum 2.0 Beacon Chain";
    homepage = "https://github.com/ConsenSys/teku";
    license = licenses.asl20;
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
}
