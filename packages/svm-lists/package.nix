{
  lib,
  stdenvNoCC,
}:

let
  archToList = {
    x86_64-linux = ./linux-amd64.json;
    aarch64-linux = ./linux-arm64.json;
    x86_64-darwin = ./macosx-amd64.json;

    # there are no upstream aarch64 binaries, "x86" ones work either thanks to Rosetta, or since 0.8.25 they are universal
    aarch64-darwin = ./macosx-amd64.json;
  };
in
stdenvNoCC.mkDerivation { 
  pname = "svm-lists";
  version = "unstable";

  dontUnpack = true;

  installPhase = ''
      install -D ${archToList.${stdenvNoCC.hostPlatform.system}} $out/list.json
      '';

  passthru = {
    category = "Development Tools";
  };

  meta = with lib; {
    description = "file metadata for current and historical builds of the Solidity Compiler";
    homepage = "https://github.com/argotorg/solc-bin";
    license = with licenses; [
      gpl3
    ];

    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
