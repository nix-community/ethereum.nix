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
  version = "2.6.5";

  src = fetchFromGitHub {
    owner = "maticnetwork";
    repo = "bor";
    rev = "v${version}";
    hash = "sha256-5kjje2x+o4NN2brUGuf5Jif7TlcDNMGPyp1i971IBa4=";
  };

  proxyVendor = true;
  vendorHash = "sha256-JU6d+SsJvjNoYTOyv0O6hWY1gItTPaiEJO32+z3lkT8=";

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
