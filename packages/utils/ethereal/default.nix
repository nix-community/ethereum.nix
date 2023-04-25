{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "ethereal";
  version = "2.8.8";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-YWgX4ffOZahA1AlSm03K75dVSEpFN/UUtQgsER2npZc=";
  };

  vendorSha256 = "sha256-Dr/csxAsPek1LMXaLSs6vlEkmv7ql2vPCPx8jCBQGCc=";

  doCheck = false;

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum";
    homepage = "https://github.com/wealdtech/ethereal/";
    license = licenses.apsl20;
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
