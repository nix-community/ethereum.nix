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
  version = "1.38.0";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = "ethdo";
    rev = "v${version}";
    hash = "sha256-3EBewLrtpVB/nKWfI4b828JoaggdKh95RdSm8cQ1Fsc=";
  };

  runVend = true;
  vendorHash = "sha256-G/NG9k5ima/SHrXt676xITzGvDvm/Jc5927PUgMe2KA=";

  nativeBuildInputs = [clang];
  buildInputs = [mcl bls];

  doCheck = false;

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum 2";
    homepage = "https://github.com/wealdtech/ethdo";
    license = licenses.apsl20;
    mainProgram = "ethdo";
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
