{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "tx-fuzz";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "MariusVanDerWijden";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-pVmh5fD82lxXA7t2z/pFUKleIFG9dXdj6EXmxvWM5ck=";
  };

  vendorHash = "sha256-tJ/IHOitOQMPd9U1KUYhVKksz1Du1kKAc6ZKSYsPKKg=";

  subPackages = ["cmd/livefuzzer"];

  postInstall = ''
    mv $out/bin/livefuzzer $out/bin/tx-fuzz
  '';

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    homepage = "https://github.com/MariusVanDerWijden/tx-fuzz";
    description = "TX-Fuzz is a package containing helpful functions to create random transactions";
    changelog = "https://github.com/MariusVanDerWijden/tx-fuzz/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = pname;
    platforms = ["x86_64-linux"];
  };
}
