{
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation { 
  pname = "svm-lists";
  version = "unstable";

  dontUnpack = true;

  installPhase = ''
      install -D ${if stdenvNoCC.isDarwin then "${./macosx-amd64.json}" else "${./linux-amd64.json}"} $out/list.json
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

    # TODO: Change this to `platforms = platforms.unix;` when this is resolved:
    # https://github.com/ethereum/solidity/issues/11351
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
      "x86_64-darwin"
    ];

    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
