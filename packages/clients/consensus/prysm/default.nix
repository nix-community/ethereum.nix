{
  bls,
  blst,
  buildGoModule,
  fetchFromGitHub,
  libelf,
}:
buildGoModule rec {
  pname = "prysm";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-316bJy4outYfCs70bKL9wwQ/YTBZLt45CusBsI1lFxE=";
  };

  vendorSha256 = "sha256-Tv59UG3i9Wpv9Vf012oC2EKgtYj5FiWaySdU3qNeYpw=";

  buildInputs = [bls blst libelf];

  doCheck = false;
}
