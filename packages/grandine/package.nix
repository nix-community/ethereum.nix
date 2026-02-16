{
  autoPatchelfHook,
  fetchurl,
  gcc-unwrapped,
  lib,
  nix-update-script,
  stdenv,
  versionCheckHook,
}:
let
  selectSystem =
    attrs:
    attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  suffix = selectSystem {
    x86_64-linux = "amd64";
    aarch64-linux = "arm64";
  };
in
stdenv.mkDerivation rec {
  pname = "grandine";
  version = "2.0.1";

  src = fetchurl {
    url = "https://github.com/grandinetech/grandine/releases/download/${version}/grandine-${version}-${suffix}";
    hash = selectSystem {
      x86_64-linux = "sha256-uAGKTbUJLdu9rmFJ1jygt/hPIzPh13U90vRC5ngASdQ=";
      aarch64-linux = "sha256-frLo0ArNX2MhKUO+p/lFJmpbnpb69SStb1LeYbRWDFQ=";
    };
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
    updateScript = nix-update-script { };
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
