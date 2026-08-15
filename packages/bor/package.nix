{
  buildGoModule,
  fetchFromGitHub,
  lib,
  libudev-zero,
  nix-update-script,
  stdenv,
}:
buildGoModule rec {
  pname = "bor";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "maticnetwork";
    repo = "bor";
    rev = "v${version}";
    hash = "sha256-yijboBu4cy/Vm3ymVHPdTGLVaKkJ2G3D+qnc7kVF7T0=";
  };

  proxyVendor = true;
  vendorHash = "sha256-7tZEk+gmROoEcrzbITs5hMaWe+vxqlnlrv2c5wA/27I=";

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libudev-zero ];

  subPackages = [
    "cmd/geth"
    "cmd/cli"
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  tags = [ "urfave_cli_no_docs" ];

  # Rename cli binary to bor
  postInstall = ''
    mv $out/bin/cli $out/bin/bor
  '';

  doCheck = false;

  passthru = {
    category = "Polygon";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Official execution client of the Polygon blockchain";
    homepage = "https://github.com/maticnetwork/bor";
    license = licenses.lgpl3Only;
    mainProgram = "bor";
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
