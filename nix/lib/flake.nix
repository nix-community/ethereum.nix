lib: let
  inherit (lib) mkApp mkIf optionals elem attrByPath assertMsg mapAttrs attrValues filterAttrs;
in rec {
  platformPkgs = system:
    filterAttrs
    (_: value: let
      platforms = attrByPath ["meta" "platforms"] [] value;
    in
      elem system platforms);

  mergeForSystem = system: attrs: let
    withSystem = mapAttrs (_: v: v system) attrs;
  in
    # filter out the nulls
    filterAttrs (_: v: v != null) (
      # map entries to their content where the condition has evaluated to true
      # return null otherwise
      mapAttrs (_: v:
        if v.condition
        then v.content
        else null)
      withSystem
    );

  # Taken from flake-utils: https://github.com/numtide/flake-utils/blob/5aed5285a952e0b949eb3ba02c12fa4fcfef535f/default.nix#L195
  mkApp = {
    drv,
    name ? drv.pname or drv.name,
    exePath ? drv.passthru.exePath or "/bin/${name}",
  }: {
    type = "app";
    program = "${drv}${exePath}";
  };

  mkAppForSystem = {
    self',
    drvName,
    name ? drv: attrByPath ["pname"] drv.name drv,
    exePath ? drv: attrByPath ["passthru" "exePath"] "/bin/${name drv}" drv,
  }: system: let
    drv = attrByPath [drvName] null self'.packages;
    platforms =
      if drv != null
      then attrByPath ["meta" "platforms"] [] drv
      else [];
  in
    mkIf (elem system platforms)
    (mkApp {
      inherit drv;
      name = name drv;
      exePath = exePath drv;
    });
}
