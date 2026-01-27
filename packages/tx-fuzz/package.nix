{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "tx-fuzz";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "MariusVanDerWijden";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-CqxCquPfxyKL6ck7YCnpq9Yj2jdBOO36xf9ojIr/0bk=";
  };

  vendorHash = "sha256-s5cbutqpaXhNRT4HORrSmSLelQAzQCgkyLRJfM66bHQ=";

  subPackages = [ "cmd/livefuzzer" ];

  postInstall = ''
    mv $out/bin/livefuzzer $out/bin/tx-fuzz
  '';

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    homepage = "https://github.com/MariusVanDerWijden/tx-fuzz";
    description = "TX-Fuzz is a package containing helpful functions to create random transactions";
    changelog = "https://github.com/MariusVanDerWijden/tx-fuzz/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
