{
  fetchFromGitHub,
  lib,
  openssl,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "mev-rs";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "ralexstokes";
    repo = pname;
    rev = "main"; # Using main for now as version 0.2.1 doesn't include Cargo.lock
    sha256 = "sha256-s8QUUQxh4iEOKW5wExzIuCboNjbLggYzkrfv4Wb8cWA=";
  };

  cargoSha256 = "sha256-Ry3Kc3yRa5bg38xjSzP2jebGcK1qD0KryqX8a+87rSo=";

  buildInputs = [openssl];

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;
  OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
  OPENSSL_DIR = "${lib.getDev openssl}";

  meta = {
    homepage = "https://github.com/ralexstokes/mev-rs";
    description = "A gateway to a network of block builders";
  };
}
