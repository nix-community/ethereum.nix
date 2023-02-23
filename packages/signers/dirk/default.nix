{
  buildGoModule,
  fetchFromGitHub,
  mcl,
  bls,
}:
buildGoModule rec {
  pname = "dirk";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-LrXuiBRfG93fYBQRJHfWw9tJz2RuP6bqU5ii1YBhiKI=";
  };

  runVend = true;
  vendorSha256 = "sha256-CyOUXwAPKHGK6xt15iFMOBVgpBtn5efGecj6PckmgBk=";

  buildInputs = [mcl bls];

  doCheck = false;

  meta = {
    description = "An Ethereum 2 distributed remote keymanager, focused on security and long-term performance of signing operations";
    homepage = "https://github.com/attestantio/dirk";
    platforms = ["x86_64-linux"];
  };
}
