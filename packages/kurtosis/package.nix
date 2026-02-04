{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
let
  inherit (stdenvNoCC.hostPlatform) system;

  version = "1.15.2";

  kurtosisBinVersions = builtins.fromJSON (builtins.readFile ./hashes.json);

  platformSpec = kurtosisBinVersions.${system};
in
stdenvNoCC.mkDerivation {
  pname = "kurtosis-cli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/kurtosis-tech/kurtosis-cli-release-artifacts/releases/download/${version}/kurtosis-cli_${version}_${platformSpec.platformSuffix}.tar.gz";
    inherit (platformSpec) hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -D -m755 kurtosis $out/bin/kurtosis

    runHook postInstall
  '';

  passthru = {
    category = "Development Tools";
    updateScript = ./update.sh;
  };

  meta = with lib; {
    description = "CLI for Kurtosis, a framework for building and running distributed systems";
    homepage = "https://github.com/kurtosis-tech/kurtosis";
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "kurtosis";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
