{
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "zcli";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "protolambda";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Kv8wDkaHX7BELATXMtTTHx/rk1FJs6RpMbhSzfXUg0M=";
  };

  vendorHash = "sha256-ljLBpawNCXGTNXvnuodpDfrnKAFvi0e/HV1ns5EHeaE=";

  subPackages = ["."];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Eth2 CLI debugging tool";
    homepage = "https://github.com/protolambda/zcli";
    mainProgram = "zcli";
    platforms = ["x86_64-linux"];
  };
}
