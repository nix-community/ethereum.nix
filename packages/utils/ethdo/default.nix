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
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = "ethdo";
    rev = "v${version}";
    hash = "sha256-vMw5wr2HEFOXixNJwV5CeFUEPG4rpi4WE9Zn3zlRUmA=";
  };

  runVend = true;
  vendorSha256 = "sha256-X6DeaSd5/NkPUN0J/0QeRhC+2oVjNbH7Vxfn6eWXrqc=";

  nativeBuildInputs = [clang];
  buildInputs = [mcl bls];

  doCheck = false;

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum 2";
    homepage = "https://github.com/wealdtech/ethdo";
    license = licenses.apsl20;
    mainProgram = "ethdo";
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
