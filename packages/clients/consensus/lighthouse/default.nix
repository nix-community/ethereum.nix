{
  cmake,
  fetchFromGitHub,
  llvm,
  pkg-config,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "lighthouse";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "sigp";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-HaoqpwCWyP9A4qWfwDDED4pSsk82oI0ZiipkNJLcIBY=";
  };

  nativeBuildInputs = [cmake pkg-config llvm];

  meta = {
    description = "Ethereum consensus client in Rust";
    homepage = "https://github.com/sigp/lighthouse";
  };
}
