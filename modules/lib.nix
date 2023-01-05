lib: let
  inherit (lib.lists) flatten;
  inherit (lib.strings) concatStringsSep;

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
  script = {
    inherit flag arg optionalArg joinArgs;
  };
}
