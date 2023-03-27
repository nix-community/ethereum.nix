{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
}:
buildGoModule rec {
  pname = "charon";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-hcGg/TYp+a3cVEf7wqf1k7eco3Z3WCjtRu2KudB70BI=";
  };

  vendorSha256 = "sha256-ntXD4q6VkKtbs2iMz8u7QJL9g+N40ATdS74wvFmt33M=";

  buildInputs = [bls mcl];

  ldflags = ["-s" "-w"];

  subPackages = ["."];

  meta = {
    description = "Charon (pronounced 'kharon') is a Proof of Stake Ethereum Distributed Validator Client";
    homepage = "https://github.com/ObolNetwork/charon";
    platforms = ["x86_64-linux"];
  };
}
