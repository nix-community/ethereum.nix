{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "builder";
  version = "1.11.5-0.2.1";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-xCxBj4eUtRRkZYMUlzZ/PUGbqyBixyUEJzSF6EWS7SM=";
  };

  vendorSha256 = "sha256-Fh72oZNSJrglW3TiZDd8aHQixmZfipB0e2gQMXUaZzI=";

  buildInputs = [blst];

  subPackages = ["cmd/geth"];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Flashbots mev-boost block builder";
    homepage = "https://github.com/flashbots/builder";
    platforms = ["x86_64-linux"];
  };
}
