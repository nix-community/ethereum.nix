{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "blst";
  version = "0.3.10";

  src = fetchFromGitHub {
    owner = "supranational";
    repo = "blst";
    rev = "v${version}";
    hash = "sha256-xero1aTe2v4IhWIJaEDUsVDOfE77dOV5zKeHWntHogY=";
  };

  builder = ./builder.sh;

  meta = {
    description = "Multilingual BLS12-381 signature library";
    homepage = "https://github.com/supranational/blst";
    platforms = ["x86_64-linux"];
  };
}
