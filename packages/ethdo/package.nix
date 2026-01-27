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
  version = "1.39.0";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = "ethdo";
    rev = "v${version}";
    hash = "sha256-wxz2WTlvLKKVrPl4kMhtXukERafATZNGyzsmsPdRWWY=";
  };

  runVend = true;
  vendorHash = "sha256-9WzDizPvZOygwvYo4thVSWEDy0Z7ii7tLRwNPaoZKSg=";

  nativeBuildInputs = [ clang ];
  buildInputs = [
    mcl
    bls
  ];

  doCheck = false;

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum 2";
    homepage = "https://github.com/wealdtech/ethdo";
    license = licenses.apsl20;
    mainProgram = "ethdo";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
