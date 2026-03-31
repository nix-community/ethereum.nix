{
  autoPatchelfHook,
  fetchurl,
  gcc-unwrapped,
  lib,
  stdenv,
  versionCheckHook,
}:
let
  hashes = lib.importJSON ./hashes.json;
  metadata =
    hashes.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation rec {
  pname = "grandine";
  version = "2.0.4";

  src = fetchurl {
    inherit (metadata) url hash;
  };

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ gcc-unwrapped.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/grandine
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  passthru = {
    category = "Consensus Clients";
    updateScript = ./update.py;
  };

  meta = {
    description = "High performance Ethereum consensus client";
    homepage = "https://github.com/grandinetech/grandine";
    license = lib.licenses.gpl3Only;
    mainProgram = "grandine";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
