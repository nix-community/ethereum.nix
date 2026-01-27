{
  fetchFromGitHub,
  lib,
  stdenv,
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

  passthru.category = "Libraries";

  meta = {
    description = "Multilingual BLS12-381 signature library";
    homepage = "https://github.com/supranational/blst";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
