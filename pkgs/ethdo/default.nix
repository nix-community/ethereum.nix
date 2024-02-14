{
  bls,
  buildGoModule,
  clang,
  fetchFromGitHub,
  lib,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "ethdo";
  version = "1.35.2";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = "ethdo";
    rev = "v${version}";
    hash = "sha256-A+0fGYhC3BmZzFr/5qeCV31izELILj9gm2IPTheiAas=";
  };

  runVend = true;
  vendorHash = "sha256-+F5zUYtfwiafop2fpVFjXxCAAYHLAemjJAxWcHtKmCs=";

  nativeBuildInputs = [clang];
  buildInputs = [mcl bls];

  doCheck = false;

  passthru.updateScript = nix-update-script {
     extraArgs = ["--flake"];
  };

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum 2";
    homepage = "https://github.com/wealdtech/ethdo";
    license = licenses.apsl20;
    mainProgram = "ethdo";
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
