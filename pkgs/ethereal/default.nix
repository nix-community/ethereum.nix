{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "ethereal";
  version = "2.8.10";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-UuKvvce6qgOSZ/MEydrzpXtnrcEEmxasJ3KTh6efQVM=";
  };

  vendorHash = "sha256-fYl7DynYbMuebRzWps/M4MkHv4u4CW3Ao9UothvRDoc=";

  doCheck = false;

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum";
    homepage = "https://github.com/wealdtech/ethereal/";
    license = licenses.apsl20;
    mainProgram = "ethereal";
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
