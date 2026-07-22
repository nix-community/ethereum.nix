{
  coreutils,
  fetchurl,
  findutils,
  gnused,
  jre,
  lib,
  makeWrapper,
  nix-update-script,
  stdenv,
  versionCheckHook,
}:
stdenv.mkDerivation rec {
  pname = "teku";
  version = "26.7.1";

  src = fetchurl {
    url = "https://artifacts.consensys.net/public/${pname}/raw/names/${pname}.tar.gz/versions/${version}/${pname}-${version}.tar.gz";
    hash = "sha256-h6q4o04XJ21s0S1IWvmOFmlqeXUte8LPTgx7In1hhwQ=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r bin $out/
    mkdir -p $out/lib
    cp -r lib $out/
    # The upstream launcher script relies on `uname` (coreutils), `xargs`
    # (findutils) and `sed` (gnused) being on PATH to assemble the JVM invocation.
    wrapProgram $out/bin/${pname} \
      --set JAVA_HOME "${jre}" \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          findutils
          gnused
        ]
      }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

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
