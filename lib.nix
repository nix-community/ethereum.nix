lib: rec {
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
}
