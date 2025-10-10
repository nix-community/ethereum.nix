{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "blst";
  version = "0.3.16";

  src = fetchFromGitHub {
    owner = "supranational";
    repo = "blst";
    rev = "v${version}";
    hash = "sha256-wQ5dHFnYqrWC4vl+7OJ/utcuTXdBtN26q0OsNPW0kfs=";
  };

  builder = ./builder.sh;

  meta = {
    description = "Multilingual BLS12-381 signature library";
    homepage = "https://github.com/supranational/blst";
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
