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
  version = "1.11.4";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    hash = "sha256-cg6bjynnYqfES7cytXxtw1ZwS1GtVpQepgTGZmHFecs=";
  };

  # Use the module cache instead of `go mod vendor`, which strips the prebuilt
  # static libraries (e.g. libhashtree.a) shipped by
  # github.com/pk910/hashtree-bindings since 1.10, as they live in directories
  # without Go source files.
  proxyVendor = true;
  vendorHash = "sha256-a6Fu7Q3zNux5vCI+F5KsDlZjbkjtFocAPyFWZMhxgeI=";

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
    changelog = "https://github.com/ObolNetwork/charon/releases";
    license = lib.licenses.bsl11;
    mainProgram = "charon";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
