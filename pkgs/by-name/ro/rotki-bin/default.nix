{
  appimageTools,
  fetchurl,
  lib,
  makeWrapper,
  nix-update-script,
}:
appimageTools.wrapType2 rec {
  pname = "rotki-bin";
  version = "1.39.0";

  src = fetchurl {
    url = "https://github.com/rotki/rotki/releases/download/v${version}/rotki-linux_x86_64-v${version}.AppImage";
    sha256 = "sha256-KBNTPIdyUUkNxj5svVpBsQNI1jcFCdYQ5Z5G4CK8KXg=";
  };

  nativeBuildInputs = [makeWrapper];

  extraInstallCommands = let
    contents = appimageTools.extract {inherit pname version src;};
  in ''
    mv $out/bin/{rotki-bin,rotki}
    wrapProgram $out/bin/rotki \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
    install -Dm444 ${contents}/rotki.desktop -t $out/share/applications/
    install -Dm444 ${contents}/rotki.png -t $out/share/icons/hicolor/1024x1024/apps/
    substituteInPlace $out/share/applications/rotki.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=rotki' \
  '';

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "An open source portfolio tracking tool that respects your privacy";
    homepage = "https://rotki.com/";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [mitchmindtree];
    platforms = ["x86_64-linux"];
  };
}
