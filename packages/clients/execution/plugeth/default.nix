{mkGeth}:
mkGeth {
  name = "plugeth";
  version = "1.10.25.0.0";
  owner = "openrelayxyz";
  repo = "plugeth";
  sha256 = "sha256-sibt+rud2eNskC4TXbWUOCmvzpwUEdTSi/WQiu4Mwpc=";
  vendorSha256 = "sha256-xP4jbaQUB3VvyD8sktfFpTDUZVEKtskqkVb/GkTYp54=";
  bins = ["geth"];
  subPackages = ["cmd/geth"];
}
