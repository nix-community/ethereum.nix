{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.22.0";

  src = fetchFromGitHub {
    owner = "ethpandaops";
    repo = "dora";
    rev = "v${version}";
    hash = "sha256-yW/cjJt65B9f+k2E9Dnz6Fxdmkp0osOcSEz/48SyDwk=";
  };

  ui = buildNpmPackage {
    pname = "dora-ui";
    inherit version src;

    sourceRoot = "${src.name}/ui-package";

    npmDepsHash = "sha256-89xg9pKyXOf47k4jd53tCoE1GIJYJkGWnQbdVnIuIFk=";
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
  vendorHash = "sha256-89xg9pKyXOf47k4jd53tCoE1GIJYJkGWnQbdVnIuIFk=";

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
