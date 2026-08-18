{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.21.0";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-59BbUwVmVJk+ThlyPoX7OMjaoDUajTL8hrbNJjCJFRQ=";
  };

  vendorHash = "sha256-kLLJvQRweIX0G6JaARAFsqspk+kEe+E7ACSoYZlH0J8=";

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
