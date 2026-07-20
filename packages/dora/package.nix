{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.24.2";

  src = fetchFromGitHub {
    owner = "ethpandaops";
    repo = "dora";
    rev = "v${version}";
    hash = "sha256-DECBNhl5s//bh+MsOQLzdci7LPhh9IrJMtfvk4s9L2s=";
  };

  ui = buildNpmPackage {
    pname = "dora-ui";
    inherit version src;

    sourceRoot = "${src.name}/ui-package";

    npmDepsHash = "sha256-YfDn4h7Aq359X9X1kbJu0o64Z9LAJxz9PyF6TofKxcc=";
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
  vendorHash = "sha256-RqqgGw5qapy5vpz+4c81Tv5mJRQGY22m/GYaaZkZ/eA=";

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
