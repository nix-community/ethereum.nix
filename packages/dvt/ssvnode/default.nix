{
  bls,
  mcl,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "ssv";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "bloxapp";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-AglorMoa7NJlSw13jqR0GDGzzsF93iL8DHbdKq4m3s0=";
  };

  vendorHash = "sha256-wL5UzetQKYl9fWIlOZKjimbhWyIBv+orugDq8sqQGIs=";

  buildInputs = [bls mcl];

  subPackages = ["cmd/ssvnode"];

  meta = {
    description = "Secret-Shared-Validator(SSV) for ethereum staking";
    homepage = "https://github.com/bloxapp/ssv";
    platforms = ["x86_64-linux"];
    mainProgram = "ssvnode";
  };
}
