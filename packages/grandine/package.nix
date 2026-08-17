{
  autoPatchelfHook,
  fetchurl,
  gcc-unwrapped,
  lib,
  stdenv,
}:
let
  hashes = lib.importJSON ./hashes.json;
  metadata =
    hashes.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation rec {
  pname = "grandine";
  version = "2.0.6";

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

  # versionCheckHook cannot be used: upstream forgot to bump
  # grandine_version/Cargo.toml for the 2.0.6 release, so the published binaries
  # report "Grandine 2.0.5". Smoke-test that the binary runs and reports some
  # version instead. See https://github.com/grandinetech/grandine/issues/838
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/grandine --version | grep -E '^Grandine [0-9]+\.[0-9]+\.[0-9]+$'
    runHook postInstallCheck
  '';

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
