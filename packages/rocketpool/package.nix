{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.20.2";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-h/SqJ2y/cjtBQDPmew++a0f9Q6QheVC0IryN0kDJ2aA=";
  };

  vendorHash = "sha256-h9cUUNL8Z0rSPdmCKeLxVflw3tiUmpD4k9Y6pjx1tWc=";

  subPackages = [ "rocketpool-cli" ];

  postInstall = ''
    mv $out/bin/rocketpool-cli $out/bin/rocketpool
  '';

  passthru = {
    category = "Staking";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Rocket Pool CLI";
    homepage = "https://github.com/rocket-pool/smartnode";
    license = lib.licenses.gpl3Only;
    mainProgram = "rocketpool";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
