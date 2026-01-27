{
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "zcli";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "protolambda";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-5bsix9kKualpTYSDQDiz0qiUYbswvl2smsRgUg+L1iM=";
  };

  vendorHash = "sha256-LgkyLWWT5wBy/WMr/961S6gpGJj9f0oZWMvx6MHugl4=";

  subPackages = [ "." ];

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Eth2 CLI debugging tool";
    homepage = "https://github.com/protolambda/zcli";
    mainProgram = "zcli";
    platforms = [ "x86_64-linux" ];
  };
}
