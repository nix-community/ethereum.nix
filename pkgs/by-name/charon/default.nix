{
  bls,
  buildGoModule,
  fetchFromGitHub,
  mcl,
  nix-update-script,
}:
buildGoModule rec {
  pname = "charon";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "ObolNetwork";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    hash = "sha256-qXlX539ssDiaw2NzMlVsDHBNJkwviqcWcc4MvE2V3us=";
  };

  vendorHash = "sha256-/qdRdqGpyfPD8kV4jf3963ttr+59q05a6fvAt9A+Oiw=";

  buildInputs = [bls mcl];

  ldflags = ["-s" "-w"];

  subPackages = ["."];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Charon (pronounced 'kharon') is a Proof of Stake Ethereum Distributed Validator Client";
    homepage = "https://github.com/ObolNetwork/charon";
    mainProgram = "charon";
    platforms = ["x86_64-linux"];
  };
}
