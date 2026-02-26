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
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "maticnetwork";
    repo = "bor";
    rev = "v${version}";
    hash = "sha256-iDmJ/ADq1U4XvgfoVjx9uGpJKed9Gy0unrygMmi0EnY=";
  };

  proxyVendor = true;
  vendorHash = "sha256-1HFjuatvMyP/Hky10RSUgcN2BSTD4EWBvmLuRIFjt70=";

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
