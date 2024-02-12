{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "blst";
  version = "0.3.11";

  src = fetchFromGitHub {
    owner = "supranational";
    repo = "blst";
    rev = "v${version}";
    hash = "sha256-oqljy+ZXJAXEB/fJtmB8rlAr4UXM+Z2OkDa20gpILNA=";
  };

  builder = ./builder.sh;

  meta = {
    description = "Multilingual BLS12-381 signature library";
    homepage = "https://github.com/supranational/blst";
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
