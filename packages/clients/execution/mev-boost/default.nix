{
  mkGeth,
  blst,
}:
mkGeth {
  name = "mev-boost";
  version = "0.8.2";
  owner = "flashbots";
  repo = "mev-boost";
  sha256 = "sha256-Cx5BL8ZR54MsuAvfVgUpC4+VMDS6gLUGgRa+sT+x3nw=";
  vendorSha256 = "sha256-HKp3zCOOiRmn25cSKlAo6/S/bqKFBmMzRbyDDwdQkzc=";
  subPackages = ["cmd/mev-boost"];
  buildInputs = [blst];
  bins = [];
}
