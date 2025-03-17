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
    hash = "sha256-d8HIZx33ZRcZgdEBAuCa21/ivh/XKlQf+Sn2aZbth4E=";
  };

  cargoSha256 = "sha256-XwJDis7lfmlYFSRVesusa9jHUGoAoDOsFo8DCFiQMzU=";
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "anvil-rpc-0.1.0" = "sha256-L38OioxnWEn94g3GJT4j3U1cJZ8jQDHp8d1QOHaVEuU=";
      "beacon-api-client-0.1.0" = "sha256-vqTC7bKXgliN7qd5LstNM5O6jRnn4aV/paj88Mua+Bc=";
      "ethereum-consensus-0.1.1" = "sha256-FbXd6qKSqqOHY7AAtfySRm1XyIPRwAYmUiWAebIc1b0=";
      "ssz-rs-0.8.0" = "sha256-Gvws9twDoRCdVLCMQCXrKbip3Wa7eEv6K+Pu8Ly3aQ0=";
    };
  };

  buildInputs = [openssl];

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;
  OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
  OPENSSL_DIR = "${lib.getDev openssl}";

  meta = {
    description = "A gateway to a network of block builders";
    homepage = "https://github.com/ralexstokes/mev-rs";
    mainProgram = "mev";
    platforms = ["x86_64-linux"];
  };
}
