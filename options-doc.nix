{
  lib,
  nixosOptionsDoc,
  runCommand,
  fetchurl,
  pandoc,
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

  optionsModule = {lib, ...}: let
    eachOptions = with lib;
      filterAttrs
      (_: hasSuffix "options.nix")
      (fs.flattenTree {tree = fs.rakeLeaves ./modules;});
  in {
    imports = lib.attrValues (builtins.trace eachOptions eachOptions);
  };

  eval = lib.evalModules {
    modules = [
      optionsModule
    ];
  };
  options = nixosOptionsDoc {
    inherit (eval) options;
  };

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
#  runCommand "reference.md" {} ''
#    cat >$out <<EOF
#    # NixOS Options
#    EOF
#    cat ${options.optionsCommonMark} >>$out
#  ''

