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
  version = "2.8.3";

  src = fetchFromGitHub {
    owner = "maticnetwork";
    repo = "bor";
    rev = "v${version}";
    hash = "sha256-MdRi3eKsCTtvwATSDS8P+7PsQoZySQs2a7mLJEDGwL4=";
  };

  proxyVendor = true;
  vendorHash = "sha256-u0ZB4ZQWtGIaMAU9NEgQm/iWs0QinJpaB1xVAbREmbk=";

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
