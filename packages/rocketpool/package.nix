{
  buildGo127Module,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGo127Module rec {
  pname = "rocketpool";
  version = "1.24.4";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-qP4Dd2q3FUqo+MHdSHe8T8R64U3rmRX4SzQLgNjAubA=";
  };

  vendorHash = "sha256-9T9hN1ep3OiWf82hTSx/0WsXdAjiHghzz2hMhv727I4=";

  subPackages = [ "rocketpool-cli" ];

  postInstall = ''
    mv $out/bin/rocketpool-cli $out/bin/rocketpool
  '';

  passthru = {
    category = "Staking Tools";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Rocket Pool CLI";
    homepage = "https://github.com/rocket-pool/smartnode";
    changelog = "https://github.com/rocket-pool/smartnode/releases";
    license = lib.licenses.gpl3Only;
    mainProgram = "rocketpool";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
