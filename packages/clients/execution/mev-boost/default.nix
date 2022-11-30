{
  mkGeth,
  blst,
}:
mkGeth {
  name = "mev-boost";
  version = "1.4.0";
  owner = "flashbots";
  repo = "mev-boost";
  sha256 = "sha256-rtjo7h4NyBYYyR3wJG9YIIxojyPy2is/EDalDbIJV10=";
  vendorSha256 = "sha256-w6ysybC3i3p/UZJbF7hL9ZycmRoGbeQNJWle5zfDg3M=";
  subPackages = ["cmd/mev-boost"];
  buildInputs = [blst];
  bins = [];
}
