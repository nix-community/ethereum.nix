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
  version = "1.28.4";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = "ethdo";
    rev = "v${version}";
    hash = "sha256-sZYOC/LAyiXRTy2tOxmf/8NPjjD9la/i3DpA1ZowbdY=";
  };

  runVend = true;
  vendorSha256 = "sha256-QYTt6QLGIw9z0kpJ1jdyvpoydfVeqhST28HwgMdOXEI=";

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
