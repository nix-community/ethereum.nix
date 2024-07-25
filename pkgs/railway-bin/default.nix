{
  lib,
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType2 rec {
  pname = "railway-bin";
  version = "5.17.0";

  src = fetchurl {
    url = "https://github.com/Railway-Wallet/Railway-Wallet/releases/download/v${version}/Railway-linux-x86_64.AppImage";
    sha256 = "sha256-6IBVbBkYJ6Qsh87sVbx/SKRC43M9D7RElBuOo+5MA14=";
  };

  meta = with lib; {
    description = "A private defi wallet";
    homepage = "https://www.railway.xyz/";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [wanderer];
    platforms = ["x86_64-linux"];
  };
}
