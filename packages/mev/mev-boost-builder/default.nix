{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "builder";
  version = "1.11.5-0.2.2";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-UbbsL1qzitBCp7t8uDPPFhB8PjK3zan6BNdKrHA+bY0=";
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
