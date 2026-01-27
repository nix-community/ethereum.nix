{
  fetchzip,
  jre,
  lib,
  makeWrapper,
  nix-update-script,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "web3signer";
  version = "25.12.0";

  src = fetchzip {
    url = "https://github.com/Consensys/${pname}/releases/download/${version}/${pname}-${version}.tar.gz";
    hash = "sha256-/oJ8aSLMz7xqvz9JcmifxtPS+BOwmRnBsQA527E877s=";
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
    category = "Validators";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Web3Signer is an open-source signing service capable of signing on multiple platforms (Ethereum1 and 2, Filecoin) using private keys stored in an external vault, or encrypted on a disk";
    homepage = "https://github.com/ConsenSys/web3signer";
    license = licenses.apsl20;
    mainProgram = "web3signer";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
  };
}
