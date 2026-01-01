{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "dirk";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "attestantio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-uYS1yaXsooUsx84EPAV1+pT6d9yK3y9SqpsGQwtKmR8=";
  };

  runVend = true;
  vendorHash = "sha256-SlYg3QFHXh6jlZFGIFLivydGVZHocF/CZHbSg4Q/4r0=";

  buildInputs = [mcl bls];

  doCheck = false;

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "An Ethereum 2 distributed remote keymanager, focused on security and long-term performance of signing operations";
    homepage = "https://github.com/attestantio/dirk";
    mainProgram = "dirk";
    platforms = ["x86_64-linux"];
  };
}
