{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "ethereal";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-RbrSVi24LT1juP0tPIIig75V/ak9T1xtlE8ajgVIJKI=";
  };

  vendorHash = "sha256-WtFQ75tgWim76Gsg/q1yx0nkJql3wiOwmjF7KVClxXY=";

  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum";
    homepage = "https://github.com/wealdtech/ethereal/";
    license = licenses.apsl20;
    mainProgram = "ethereal";
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
