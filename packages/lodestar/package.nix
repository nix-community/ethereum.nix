{
  buildFHSEnv,
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  inherit (stdenvNoCC.hostPlatform) system;

  version = "1.40.0";

  hashes = builtins.fromJSON (builtins.readFile ./hashes.json);

  platformSpec = hashes.${system};

  unwrapped = stdenvNoCC.mkDerivation {
    pname = "lodestar-unwrapped";
    inherit version;

    src = fetchurl {
      url = "https://github.com/ChainSafe/lodestar/releases/download/v${version}/lodestar-v${version}-${platformSpec.platformSuffix}.tar.gz";
      inherit (platformSpec) hash;
    };

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -D -m755 lodestar $out/bin/lodestar
      runHook postInstall
    '';

    meta = with lib; {
      description = "TypeScript implementation of the Ethereum consensus specification";
      homepage = "https://lodestar.chainsafe.io";
      license = licenses.asl20;
      mainProgram = "lodestar";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    };
  };
in
buildFHSEnv {
  name = "lodestar";
  targetPkgs = _: [ unwrapped ];
  runScript = "lodestar";

  passthru = {
    inherit unwrapped;
    category = "Consensus Clients";
    updateScript = ./update.sh;
  };

  inherit (unwrapped) meta;
}
