{
  fetchurl,
  jre,
  lib,
  makeWrapper,
  nix-update-script,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "teku";
  version = "26.2.0";

  src = fetchurl {
    url = "https://artifacts.consensys.net/public/${pname}/raw/names/${pname}.tar.gz/versions/${version}/${pname}-${version}.tar.gz";
    hash = "sha256-O81WrAqJ42L4KWuFAuH7u35UnIb21vYvJQDL7WwelDc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r bin $out/
    mkdir -p $out/lib
    cp -r lib $out/
    wrapProgram $out/bin/${pname} --set JAVA_HOME "${jre}"
  '';

  passthru = {
    category = "Consensus Clients";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Java Implementation of the Ethereum 2.0 Beacon Chain";
    homepage = "https://github.com/ConsenSys/teku";
    license = licenses.asl20;
    mainProgram = "teku";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
  };
}
