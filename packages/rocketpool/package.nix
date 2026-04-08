{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.20.0";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-35qwfEYvZM4ZlV+unJCg5QtTJWHmua2PSGxF+gcXF3g=";
  };

  vendorHash = "sha256-e8psI01fNHIBmlfYwZmfkKYBnIV4mybDFA+Lu5+mWkQ=";

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
