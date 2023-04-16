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
  version = "1.29.2";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = "ethdo";
    rev = "v${version}";
    hash = "sha256-5//52aar7GW4V8xxl2ndee44cjMbBDRi4RZD/+jczec=";
  };

  runVend = true;
  vendorSha256 = "sha256-4W4WasFbGGMDj3kmJfaGwShOwLj+VmihaKRQQkZvH/M=";

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
