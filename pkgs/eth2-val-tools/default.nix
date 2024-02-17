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
  pname = "eth2-val-tools";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "protolambda";
    repo = "eth2-val-tools";
    rev = "v${version}";
    hash = "sha256-PkdkS0pRu2W2s9We022VzjXWZkIuuBCKMJNVkn12SWE=";
  };

  runVend = true;
  vendorHash = "sha256-ICHc5l+hMl6YgAWfwLbY/zLAgGCBjqwwGNydm/UXELM=";

  nativeBuildInputs = [clang];
  buildInputs = [mcl bls];

  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = ["--flake"];
  };

  meta = with lib; {
    description = "Some experimental tools to manage validators";
    homepage = "https://github.com/protolambda/eth2-val-tools";
    license = licenses.mit;
    mainProgram = "eth2-val-tools";
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
