{
  buildGo127Module,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGo127Module rec {
  pname = "rocketpool";
  version = "1.22.1";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-hVca3FeuMdyz1V+2zLIfRB/aPsdaGPJ9RyO+1HbBTPU=";
  };

  vendorHash = "sha256-PttgYSSuNneT8kgQT84BUagJ1x39wbA7zhYDrH6o3BI=";

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
