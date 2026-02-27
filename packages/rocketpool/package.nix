{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.19.3";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-6y5bY3QpEN0M8Ubd5FqL8O8NySjvU5+fFPvxkZ0eyms=";
  };

  vendorHash = "sha256-8a2CNruHB04FY4cGUqCJYglzanKwYdcOFMnl9yTQDHI=";

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
