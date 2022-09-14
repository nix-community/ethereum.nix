{mkGeth}:
mkGeth {
  name = "plugeth";
  version = "1.10.18.0.0";
  owner = "openrelayxyz";
  repo = "plugeth";
  sha256 = "sha256-FhQe3WIzc35zgtE10cHpif2f7bJcz/rYo9SzT5FCZqk=";
  vendorSha256 = "sha256-JtBWNMbRtJnwTVcwBXwmKV+6OeghFxs2GQVJike5BbQ=";
  bins = ["geth"];
  subPackages = ["cmd/geth"];
}
