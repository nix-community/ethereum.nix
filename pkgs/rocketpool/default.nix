{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "rocketpool";
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "rocket-pool";
    repo = "smartnode";
    rev = "v${version}";
    hash = "sha256-T6IvtfS808lDhODEG0Lr1B8MJXy5QAxvjzwowpgMgvE=";
  };

  vendorHash = "sha256-W5DiHrthiPdYYiR9Esnghrs8a7+UzdPlVYRRwDjpnFU=";

  subPackages = ["rocketpool-cli"];

  postInstall = ''
    mv $out/bin/rocketpool-cli $out/bin/rocketpool
  '';

  meta = {
    description = "Rocket Pool CLI";
    homepage = "https://github.com/rocket-pool/smartnode";
    mainProgram = "rocketpool";
    platforms = ["aarch64-linux" "x86_64-linux"];
  };
}
