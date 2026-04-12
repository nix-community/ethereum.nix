{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.20.4";

  src = fetchFromGitHub {
    owner = "ethpandaops";
    repo = "dora";
    rev = "v${version}";
    hash = "sha256-R7V6D+kwLm/V8sz5pw8Eo9Mm4BpJhBjwQUjaSykwbvA=";
  };

  ui = buildNpmPackage {
    pname = "dora-ui";
    inherit version src;

    sourceRoot = "${src.name}/ui-package";

    npmDepsHash = "sha256-ETAZLuq6MQNt5PmZmjHzX/raXPyfL8IAoBNOCF6mTsY=";
    npmFlags = [ "--legacy-peer-deps" ];
    makeCacheWritable = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist/* $out/
      runHook postInstall
    '';
  };
in
buildGoModule rec {
  pname = "dora";
  inherit version src;

  proxyVendor = true;
  vendorHash = "sha256-ETAZLuq6MQNt5PmZmjHzX/raXPyfL8IAoBNOCF6mTsY=";

  preBuild = ''
    mkdir -p ui-package/dist
    cp -r ${ui}/* ui-package/dist/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  doCheck = false;

  passthru = {
    category = "Utilities";
    updateScript = ./update.py;
  };

  meta = {
    description = "Lightweight beaconchain explorer for Ethereum";
    homepage = "https://github.com/ethpandaops/dora";
    license = lib.licenses.gpl3Only;
    mainProgram = "dora-explorer";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
