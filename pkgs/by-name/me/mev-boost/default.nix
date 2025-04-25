{
  blst,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "mev-boost";
  version = "1.9";
  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-VBvbiB7M6X+bQ5xEwmJo5dptiR7PIBiFDqkg1fyU8ro=";
  };

  vendorHash = "sha256-OyRyMsINy4I04E2QvToOEY7UKh2s6NUeJJO0gJI5uS0=";

  buildInputs = [blst];

  subPackages = ["cmd/mev-boost"];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "MEV-Boost allows proof-of-stake Ethereum consensus clients to source blocks from a competitive builder marketplace";
    homepage = "https://github.com/flashbots/mev-boost";
    mainProgram = "mev-boost";
    platforms = ["x86_64-linux"];
  };
}
