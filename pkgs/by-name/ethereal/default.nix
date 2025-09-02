{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule rec {
  pname = "ethereal";
  version = "2.11.5";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-P9JIclquejwZ14NbHalfaBvLu0oHKaXt3mmlMbnr5G8=";
  };

  proxyVendor = true;
  vendorHash = "sha256-TnWN5FW1xEkHIJ/nhhc1mHAk14O65Wi43zD2FZctBBQ=";

  doCheck = false;

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "A command-line tool for managing common tasks in Ethereum";
    homepage = "https://github.com/wealdtech/ethereal/";
    license = licenses.apsl20;
    mainProgram = "ethereal";
    platforms = ["x86_64-linux" "aarch64-darwin"];
  };
}
