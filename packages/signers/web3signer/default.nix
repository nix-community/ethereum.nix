{
  fetchzip,
  jre,
  lib,
  makeWrapper,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "web3signer";
  version = "22.11.0";

  src = fetchzip {
    url = "https://artifacts.consensys.net/public/${pname}/raw/names/${pname}.tar.gz/versions/${version}/${pname}-${version}.tar.gz";
    sha256 = "sha256-zF2rv+Vjxd4LIFujK67MQgPCFZ3SiOKRfetd2CjuY84=";
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
    description = "Web3Signer is an open-source signing service capable of signing on multiple platforms (Ethereum1 and 2, Filecoin) using private keys stored in an external vault, or encrypted on a disk";
    homepage = "https://github.com/ConsenSys/web3signer";
    license = licenses.apsl20;
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
}
