{
  blst,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mev-boost";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-GAi55+BtYtqhB83TKAF/AVeR7T9/F1fkX6el5Tw6OrI=";
  };

  vendorSha256 = "sha256-+6h6q+AOQII9TxI595LKdoT6T75q/8zlARE868YsBdw=";

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
