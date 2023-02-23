{
  fetchFromGitHub,
  lib,
  openssl,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "mev-rs";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "ralexstokes";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-d8HIZx33ZRcZgdEBAuCa21/ivh/XKlQf+Sn2aZbth4E=";
  };

  cargoSha256 = "sha256-XwJDis7lfmlYFSRVesusa9jHUGoAoDOsFo8DCFiQMzU=";

  buildInputs = [openssl];

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;
  OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
  OPENSSL_DIR = "${lib.getDev openssl}";

  meta = {
    homepage = "https://github.com/ralexstokes/mev-rs";
    description = "A gateway to a network of block builders";
    platforms = ["x86_64-linux"];
  };
}
