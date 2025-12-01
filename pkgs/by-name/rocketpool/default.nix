{
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.18.6";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-al86HO6egzMYGpSfLE1R1CG9+NQzI8h6Ol4YDnwYgmA=";
  };

  vendorHash = "sha256-ysMP53854FGGjdX2SkjH8Ml/FDWHb0JjYyo0D4QGHWA=";

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
