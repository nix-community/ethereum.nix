lib: rec {
  platformPkgs = system:
    with lib;
      filterAttrs
      (_: value: let
        platforms = attrByPath ["meta" "platforms"] [] value;
      in
        elem system platforms);

  buildApps = packages: apps:
    with lib;
      listToAttrs
      (collect (attrs: builtins.attrNames attrs == ["name" "value"])
        (mapAttrsRecursiveCond builtins.isAttrs (path: v: let
          drvName = head path;
          drv = packages.${drvName};
          name = last (init path);
          exePath = "/bin/${v}";
        in
          nameValuePair name {inherit drv name exePath;})
        apps));

  platformApps = packages: apps:
    with lib; let
      apps' = filterAttrs (name: _: elem name (attrNames packages)) apps;
      bapps = buildApps packages apps';
    in
      mapAttrs (_: mkApp) bapps;

  # Taken from flake-utils: https://github.com/numtide/flake-utils/blob/5aed5285a952e0b949eb3ba02c12fa4fcfef535f/default.nix#L195
  mkApp = {
    drv,
    name ? drv.pname or drv.name,
    exePath ? drv.passthru.exePath or "/bin/${name}",
  }: {
    type = "app";
    program = "${drv}${exePath}";
  };

  isDarwin = system: (builtins.elem system lib.platforms.darwin);
  isLinux = system: (builtins.elem system lib.platforms.linux);

  mkNixpkgs = {
    system,
    config ? {},
    inputs ? {},
    nixpkgs ?
      if (isDarwin system)
      then inputs.nixpkgs-darwin
      else inputs.nixpkgs,
  }: let
    defaultConfig = {};
  in
    import nixpkgs {
      inherit system;
      config = defaultConfig // config;
    };
}
