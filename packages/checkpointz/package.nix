{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
let
  version = "0.31.0";

  src = fetchFromGitHub {
    owner = "ethpandaops";
    repo = "checkpointz";
    rev = "v${version}";
    hash = "sha256-nKXX72MKhSbq9xkdqnzq8sQCBt5xsdcUK6pEnqzi0co=";
  };

  ui = buildNpmPackage {
    pname = "checkpointz-ui";
    inherit version src;

    sourceRoot = "${src.name}/web";

    npmDepsHash = "sha256-lD/IDVHMty57C9EVKMtl7YRX1hetIXfmxnKwIuFQneA=";

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r build/* $out/
      runHook postInstall
    '';
  };
in
buildGoModule rec {
  pname = "checkpointz";
  inherit version src;

  vendorHash = "sha256-7vV4kKHFMeQqLuOtSRArxH0yKdfUBGB/gqF4iAXi9aw=";

  preBuild = ''
    mkdir -p web/build
    cp -r ${ui}/* web/build/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ethpandaops/checkpointz/pkg/version.Release=v${version}"
  ];

  doCheck = false;
  doInstallCheck = false;

  passthru = {
    category = "Utilities";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Ethereum beacon chain checkpoint sync provider";
    homepage = "https://github.com/ethpandaops/checkpointz";
    license = lib.licenses.gpl3Only;
    mainProgram = "checkpointz";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
