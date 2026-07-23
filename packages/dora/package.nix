{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:
let
  version = "1.24.3";

  src = fetchFromGitHub {
    owner = "ethpandaops";
    repo = "dora";
    rev = "v${version}";
    hash = "sha256-wFX7gtkVZXM5nhF5uXJ//Stve2Pq+epWmcQIGKQJPUw=";
  };

  ui = buildNpmPackage {
    pname = "dora-ui";
    inherit version src;

    sourceRoot = "${src.name}/ui-package";

    npmDepsHash = "sha256-OY87TtnnDrlW+VlX1nU0Jnru79Yb5wFy1dxLFtYLRoc=";
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
  vendorHash = "sha256-OY87TtnnDrlW+VlX1nU0Jnru79Yb5wFy1dxLFtYLRoc=";

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
