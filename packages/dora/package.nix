{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.24.1";

  src = fetchFromGitHub {
    owner = "ethpandaops";
    repo = "dora";
    rev = "v${version}";
    hash = "sha256-mi2rrTfxaDaJomej9pwWar1BlmiBd8G4354Y8vVAPl4=";
  };

  ui = buildNpmPackage {
    pname = "dora-ui";
    inherit version src;

    sourceRoot = "${src.name}/ui-package";

    npmDepsHash = "sha256-S9ljB/9AT7BHEDrIbgHqT9t3Quy+LeDgdj/XDKluI6c=";
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
  vendorHash = "sha256-S9ljB/9AT7BHEDrIbgHqT9t3Quy+LeDgdj/XDKluI6c=";

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
