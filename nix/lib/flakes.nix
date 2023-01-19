_: {
  # Taken from flake-utils: https://github.com/numtide/flake-utils/blob/5aed5285a952e0b949eb3ba02c12fa4fcfef535f/default.nix#L195
  mkApp = {
    drv,
    name ? drv.pname or drv.name,
    exePath ? drv.passthru.exePath or "/bin/${name}",
  }: {
    type = "app";
    program = "${drv}${exePath}";
  };
}
