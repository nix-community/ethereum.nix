{
  lib,
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType2 rec {
  pname = "rotki-bin";
  version = "1.33.1";

  src = fetchurl {
    url = "https://github.com/rotki/rotki/releases/download/v${version}/rotki-linux_x86_64-v${version}.AppImage";
    sha256 = "sha256-gC9R9DwOOs4f3ML4gLG27Ud0uQd46tIAGZxIdQn8Rd0=";
  };

  # Rename installed bin to `rotki` to make it easier to specify in `apps.rotki-bin.bin` declaration.
  extraInstallCommands = ''
    mv "$out/bin/${pname}-${version}" "$out/bin/rotki"
  '';

  meta = with lib; {
    description = "An open source portfolio tracking tool that respects your privacy";
    homepage = "https://rotki.com/";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [mitchmindtree];
    platforms = platforms.linux;
  };
}
