{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
let
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ethpandaops";
    repo = "tracoor";
    rev = "v${version}";
    hash = "sha256-gu2yX7KBCiG7WPQPHRxxwJQpnue8m5Dy3z0jR8frMZ4=";
  };

  ui = buildNpmPackage {
    pname = "tracoor-ui";
    inherit version src;

    sourceRoot = "${src.name}/web";

    npmDepsHash = "sha256-FnsnNodGtM/B8QTYWFLMgt20GUNyG0SeEY9ANw/S/wY=";

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r build/* $out/
      runHook postInstall
    '';
  };
in
buildGoModule rec {
  pname = "tracoor";
  inherit version src;

  # Use the module cache instead of `go mod vendor`, which strips the prebuilt
  # static libraries (e.g. libhashtree.a) shipped by
  # github.com/pk910/hashtree-bindings, as they live in directories without Go
  # source files.
  proxyVendor = true;
  vendorHash = "sha256-lBb8GRTC82KyobZUtY2zsM2ED6h+E5KDOaViZeR8RzU=";

  preBuild = ''
    mkdir -p web/build
    cp -r ${ui}/* web/build/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ethpandaops/tracoor/pkg/version.Release=v${version}"
  ];

  doCheck = false;

  passthru = {
    category = "Utilities";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Ethereum beacon data and execution trace explorer";
    homepage = "https://github.com/ethpandaops/tracoor";
    license = lib.licenses.gpl3Only;
    mainProgram = "tracoor";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
