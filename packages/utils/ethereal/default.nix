{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "ethereal";
  version = "2.8.7";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-HVqC0w68Cdyh8YBVeQP5xAcrZX3jR010vHjbPF3plRY=";
  };

  vendorSha256 = "sha256-rUTgheQeWPUSievYbcjJuH4UqSA0u0FeSbxf4DPuKmc=";

  doCheck = false;

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum";
    homepage = "https://github.com/wealdtech/ethereal/";
    license = licenses.apsl20;
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
