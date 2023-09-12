lib: rec {
  /*
  Function: platformPkgs
  Synopsis: Filters Nix packages based on the target system platform.

  Parameters:
    - system (string): Target system platform (e.g., "x86_64-linux").

  Returns:
    - A filtered attribute set of Nix packages compatible with the target system.
  */
  platformPkgs = system:
    with lib;
      filterAttrs
      (_: value: let
        platforms = attrByPath ["meta" "platforms"] [] value;
      in
        elem system platforms);

  /*
  Function: buildApps
  Synopsis: Constructs attribute set of applications from Nix packages and custom apps specification.

  Parameters:
    - packages (attrset): An attribute set of Nix packages.
    - apps (attrset): Custom apps specification.

  Returns:
    - An attribute set representing built applications.
  */
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

  /*
  Function: platformApps
  Synopsis: Filters and builds platform-specific applications.

  Parameters:
    - packages (attrset): An attribute set of Nix packages.
    - apps (attrset): Custom apps specification.

  Returns:
    - An attribute set of platform-specific applications.
  */
  platformApps = packages: apps:
    with lib; let
      apps' = filterAttrs (name: _: elem name (attrNames packages)) apps;
      bapps = buildApps packages apps';
    in
      mapAttrs (_: mkApp) bapps;

  /*
  Function: mkApp
  Synopsis: Creates an "app" type for Nix flakes.

  Parameters:
    - drv (derivation): The Nix derivation.
    - name (string, optional): Name of the application.
    - exePath (string, optional): Executable path.

  Returns:
    - An "app" type attribute with 'type' and 'program' keys.
  */
  mkApp = {
    drv,
    name ? drv.pname or drv.name,
    exePath ? drv.passthru.exePath or "/bin/${name}",
  }: {
    type = "app";
    program = "${drv}${exePath}";
  };

  /*
  Function: flattenTree
  Synopsis: Flattens a nested attribute set (tree) into a single-level attribute set.

  Parameters:
    - tree (attrset): A nested attribute set

  Returns:
    - An attribute set where keys are constructed in reverse DNS notation, based on the nesting.

  Example:
    Input: { a = { b = { c = <path>; }; }; }
    Output: { "a.b.c" = <path>; }

  Description:
    The function traverses the nested attribute set and produces a flattened attribute set.
    It uses dot-based reverse DNS notation to concatenate the nested keys.
  */
  flattenTree = {
    tree,
    separator ? ".",
  }: let
    op = sum: path: val: let
      pathStr = builtins.concatStringsSep separator path;
    in
      if builtins.isPath val
      then
        (sum
          // {
            "${pathStr}" = val;
          })
      else if builtins.isAttrs val
      then
        # recurse into that attribute set
        (recurse sum path val)
      else
        # ignore that value
        sum;

    recurse = sum: path: val:
      builtins.foldl'
      (sum: key: op sum (path ++ [key]) val.${key})
      sum
      (builtins.attrNames val);
  in
    recurse {} [] tree;

  /*
  Function: rakeLeaves
  Synopsis: Recursively collects `.nix` files from a directory into an attribute set.

  Parameters:
    - dirPath (string): The directory path to collect `.nix` files from.

  Returns:
    - An attribute set mapping filenames (without the `.nix` suffix) to their paths.
  */
  rakeLeaves = dirPath: let
    collect = file: type: {
      name = lib.removeSuffix ".nix" file;
      value = let
        path = dirPath + "/${file}";
      in
        if (type == "regular")
        then path
        else rakeLeaves path;
    };

    files = builtins.readDir dirPath;
  in
    lib.filterAttrs (_n: v: v != {}) (lib.mapAttrs' collect files);

  /*
  Function: mkNixpkgs
  Synopsis: Creates a custom Nixpkgs configuration.

  Parameters:
    - system (string): Target system, e.g., "x86_64-linux".
    - inputs (attrset, optional): Custom inputs for the Nixpkgs configuration.
    - overlays (list, optional): List of overlays to apply.
    - nixpkgs (path, optional): Path to the Nixpkgs repository. Defaults to inputs.nixpkgs.
    - config (attrset, optional): Additional Nixpkgs configuration settings.

  Returns:
    - A configured Nixpkgs environment suitable for importing.

  Example:
    mkNixpkgs {
      system = "x86_64-linux";
      overlays = [ myOverlay ];
    }

  Description:
    The function imports a Nixpkgs environment with the specified target system, custom inputs,
    and overlays. It also accepts additional Nixpkgs configuration settings.
  */
  mkNixpkgs = {
    system,
    nixpkgs,
    overlays ? [],
    config ? {allowUnfree = true;},
  }:
    import nixpkgs {inherit system config overlays;};
}
