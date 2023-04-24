{
  lib,
  nixosOptionsDoc,
  runCommand,
}: let
  eachOptions = with lib;
    filterAttrs
    (_: hasSuffix "options.nix")
    (fs.flattenTree {tree = fs.rakeLeaves ./modules;});

  eachOptionsDoc = with lib;
    mapAttrs' (
      name: value:
        nameValuePair
        # take geth.options and turn it into just geth
        (head (splitString "." name))
        # generate options doc
        (nixosOptionsDoc {options = evalModules {modules = [value];};})
    )
    eachOptions;

  statements = with lib;
    concatStringsSep "\n"
    (mapAttrsToList (n: v: ''
        path=$out/${n}.md
        cat ${v.optionsCommonMark} >> $path
      '')
      eachOptionsDoc);
in
  runCommand "nixos-options" {} ''
    mkdir $out
    ${statements}
  ''
