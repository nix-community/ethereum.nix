{
  lib,
  nixosOptionsDoc,
  runCommand,
  fetchurl,
  pandoc,
}: let
  optionsModule = {lib, ...}: let
    eachOptions = with lib;
      filterAttrs
      (_: hasSuffix "options.nix")
      (fs.flattenTree {tree = fs.rakeLeaves ./modules;});
  in {
    imports = lib.attrValues eachOptions;
  };

  eval = lib.evalModules {
    modules = [
      optionsModule
    ];
  };
  options = nixosOptionsDoc {
    inherit (eval) options;
  };
in
  runCommand "reference.md" {} ''
    cat >$out <<EOF
    # NixOS Options
    EOF
    cat ${options.optionsCommonMark} >>$out
  ''
