{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "heimdall-v2";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "0xPolygon";
    repo = "heimdall-v2";
    rev = "v${version}";
    hash = "sha256-RKbOSrteBCY4sLJfi0OWrunfQC5wiA3t1LVV1oero18=";
  };

  vendorHash = "sha256-7YQzfrm9A+T8zIHo4Zgeq11Wpk/5e4RLvRl3sw4zNJI=";

  # Relax Go version requirement (nixpkgs has 1.25.5, project needs 1.25.6)
  postPatch = ''
    substituteInPlace go.mod --replace-fail "go 1.25.6" "go 1.25.5"
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
    license = licenses.gpl3Only;
    mainProgram = "heimdalld";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
