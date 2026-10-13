{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "heimdall-v2";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "0xPolygon";
    repo = "heimdall-v2";
    rev = "v${version}";
    hash = "sha256-UEi6ZCRIWjgiCFsAXEgjRZMJ05SPZMbPDeTXgmQ74X0=";
  };

  vendorHash = "sha256-ISgtFwLaXYE2fGjcbVo3BJcf4fZXqHZjav8a2EbBSz8=";

  # Relax Go version requirement (nixpkgs has 1.26.3, project needs 1.26.5)
  postPatch = ''
    substituteInPlace go.mod --replace-fail "go 1.26.5" "go 1.26.3"
  '';

  subPackages = [ "cmd/heimdalld" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/0xPolygon/heimdall-v2/version.Name=heimdall"
    "-X github.com/0xPolygon/heimdall-v2/version.ServerName=heimdalld"
    "-X github.com/0xPolygon/heimdall-v2/version.Version=${version}"
  ];

  doCheck = false;

  passthru = {
    category = "Polygon";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Official consensus client of the Polygon blockchain";
    homepage = "https://github.com/0xPolygon/heimdall-v2";
    changelog = "https://github.com/0xPolygon/heimdall-v2/releases";
    license = licenses.gpl3Only;
    mainProgram = "heimdalld";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
