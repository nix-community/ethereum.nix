{
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.18.3";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-P3N4FohT1q7SOH89pTTzu5sRSrXg+7zcnI6kDjNSvtM=";
  };

  vendorHash = "sha256-fmmeANTesBbC8Nf7NasUUAvzn+w68xm0HjttY4UD2eU=";

  subPackages = ["rocketpool-cli"];

  postInstall = ''
    mv $out/bin/rocketpool-cli $out/bin/rocketpool
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Rocket Pool CLI";
    homepage = "https://github.com/rocket-pool/smartnode";
    mainProgram = "rocketpool";
    platforms = ["aarch64-linux" "x86_64-linux"];
  };
}
