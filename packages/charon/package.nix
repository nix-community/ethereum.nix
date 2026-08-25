{
  bls_1_86,
  buildGoModule,
  fetchFromGitHub,
  lib,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "charon";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    hash = "sha256-EyuXn1nP5+H/lr6pY1qVBT0uNbwBLb7OaBoIizJK9UY=";
  };

  # Use the module cache instead of `go mod vendor`, which strips the prebuilt
  # static libraries (e.g. libhashtree.a) shipped by
  # github.com/pk910/hashtree-bindings since 1.10, as they live in directories
  # without Go source files.
  proxyVendor = true;
  vendorHash = "sha256-hCrd5Fvw7ozLfqiVklPrwN2wzY7Rc6bmNvufdkKKWj8=";

  buildInputs = [
    bls_1_86
    mcl
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];

  passthru = {
    category = "Validators";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Charon (pronounced 'kharon') is a Proof of Stake Ethereum Distributed Validator Client";
    homepage = "https://github.com/ObolNetwork/charon";
    license = lib.licenses.bsl11;
    mainProgram = "charon";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
