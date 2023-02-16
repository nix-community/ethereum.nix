{
  buildGoModule,
  fetchFromGitHub,
  clang,
  mcl,
  bls,
  ...
}:
buildGoModule rec {
  pname = "ethdo";
  version = "1.28.0";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = "ethdo";
    rev = "v${version}";
    hash = "sha256-cCUJR1TUxDXvazrOGhmpNb1YTXdtfGW3Xat5tIy0/rk=";
  };

  runVend = true;
  vendorSha256 = "sha256-lNnEyaaZR/Ong5m4YCAxPgng6wQsLiR48czVhXypZgM=";

  nativeBuildInputs = [clang];
  buildInputs = [mcl bls];

  doCheck = false;
}
