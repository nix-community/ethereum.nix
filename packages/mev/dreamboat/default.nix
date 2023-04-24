{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "dreamboat";
  version = "0.4.15";

  src = fetchFromGitHub {
    owner = "blocknative";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-f99vKMmxCHbsDKDS0tLYoOKE0ZgZWE5iY3zSrVreoPU=";
  };

  vendorSha256 = "sha256-qfWe9ggsU9Fdf1pVJaQfd50nkcGQJKj58M4025EyS0k=";

  buildInputs = [blst];

  subPackages = ["cmd/dreamboat"];

  ldflags = ["-s" "-w"];

  meta = {
    description = "An Ethereum 2.0 Relay for proposer-builder separation (PBS) with MEV-boost";
    homepage = "https://github.com/blocknative/dreamboat";
    platforms = ["x86_64-linux"];
  };
}
