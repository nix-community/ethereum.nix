{
  fetchurl,
  jre,
  lib,
  makeWrapper,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "besu";
  version = "24.1.2";

  src = fetchurl {
    url = "https://hyperledger.jfrog.io/hyperledger/${pname}-binaries/${pname}/${version}/${pname}-${version}.tar.gz";
    hash = "sha256-CC24z0+2dSeqDddX5dJUs7SX9QJ8Iyh/nAp0pqdDvwg=";
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
    description = "Besu is an Apache 2.0 licensed, MainNet compatible, Ethereum client written in Java";
    homepage = "https://github.com/hyperledger/besu";
    license = licenses.asl20;
    mainProgram = "besu";
    platforms = ["x86_64-linux"];
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
}
