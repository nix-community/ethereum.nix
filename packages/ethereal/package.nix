{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "ethereal";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-XPXID0Q0fx/3yJ5LaUBj/xqhMsoOxCNwZOX9vNT7S+k=";
  };

  proxyVendor = true;
  vendorHash = "sha256-RLcnMVx64Xz+irOo5KPjgjv6XXttVPuzAr+jJkr5ev0=";

  doCheck = false;

  passthru = {
    category = "Development Tools";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum";
    homepage = "https://github.com/wealdtech/ethereal/";
    license = licenses.apsl20;
    mainProgram = "ethereal";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
