{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) isOption foldAttrs hasAttrByPath getAttrByPath filterAttrsRecursive mapAttrsRecursive;
  inherit (lib.lists) flatten;
  inherit (lib.strings) concatStringsSep;

  tomlGenerator = pkgs.formats.toml {};

  flag = name: pred:
    if pred
    then "--${name}"
    else "";
  optionalArg = name: pred: value:
    if pred
    then "--${name} ${toString value}"
    else "";
  arg = name: value: (optionalArg name true value);

  joinArgs = args: let
    flattened = flatten args;
    filtered = builtins.filter (arg: arg != "") flattened;
  in
    concatStringsSep " \\\n" filtered;
in {
  generateToml = name: opts: cfg: let
    inherit (lib) traceVal traceSeq;
    optLeaves = filterAttrsRecursive (path: opt: isOption opt) opts;
    settings =
      mapAttrsRecursive (
        path: _:
          if (hasAttrByPath path cfg)
          then getAttrByPath path cfg
          else null
      )
      opts;
  in
    tomlGenerator.generate name settings;

  script = {
    inherit flag arg optionalArg joinArgs;
  };
}
