{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "dreamboat";
  version = "0.4.17";

  src = fetchFromGitHub {
    owner = "blocknative";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-qwv5ZbVRoJdiqQwOIjcNxNqUHq9156b4+CCe27SSxKE=";
  };

  vendorSha256 = "sha256-fjkBek1/AdBlm4plN0zPLLiqh3jHg8MA2FJs06SXkFQ=";

  buildInputs = [blst];

  subPackages = ["cmd/dreamboat"];

  ldflags = ["-s" "-w"];

  meta = {
    description = "An Ethereum 2.0 Relay for proposer-builder separation (PBS) with MEV-boost";
    homepage = "https://github.com/blocknative/dreamboat";
    platforms = ["x86_64-linux"];
  };
}
