{
  buildGoModule,
  fetchFromGitHub,
  clang,
  mcl,
  bls,
  lib,
  ...
}:
buildGoModule rec {
  pname = "ethdo";
  version = "1.28.0";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = "ethdo";
    rev = "v${version}";
    hash = "sha256-cCUJR1TUxDXvazrOGhmpNb1YTXdtfGW3Xat5tIy0/rk=";
  };

  runVend = true;
  vendorSha256 = "sha256-lNnEyaaZR/Ong5m4YCAxPgng6wQsLiR48czVhXypZgM=";

  nativeBuildInputs = [clang];
  buildInputs = [mcl bls];

  doCheck = false;

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum 2";
    homepage = "https://github.com/wealdtech/ethdo";
    license = licenses.apsl20;
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
