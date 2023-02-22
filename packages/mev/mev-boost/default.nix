{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mev-boost";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-rtjo7h4NyBYYyR3wJG9YIIxojyPy2is/EDalDbIJV10=";
  };

  vendorSha256 = "sha256-w6ysybC3i3p/UZJbF7hL9ZycmRoGbeQNJWle5zfDg3M=";

  buildInputs = [blst];

  subPackages = ["cmd/mev-boost"];

  meta = {
    description = ''
      MEV-Boost allows proof-of-stake Ethereum consensus clients to source blocks from a competitive builder marketplace
    '';
    homepage = "https://github.com/flashbots/mev-boost";
    platforms = ["x86_64-linux"];
  };
}
