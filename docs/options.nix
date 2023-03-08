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
    options = eval.options;
  };
  md =
    (runCommand "ethereum-nix-options.md" {} ''
      cat >$out <<EOF
      # Ethereum.nix options
      EOF
      cat ${options.optionsCommonMark} >>$out
    '')
    .overrideAttrs (o: {
      # Work around https://github.com/hercules-ci/hercules-ci-agent/issues/168
      allowSubstitutes = true;
    });
  css = fetchurl {
    url = "https://gist.githubusercontent.com/killercup/5917178/raw/40840de5352083adb2693dc742e9f75dbb18650f/pandoc.css";
    sha256 = "sha256-SzSvxBIrylxBF6B/mOImLlZ+GvCfpWNLzGFViLyOeTk=";
  };
in
  runCommand "ethereum-nix-options.html" {nativeBuildInputs = [pandoc];} ''
    mkdir $out
    cp ${css} $out/pandoc.css
    pandoc --css="pandoc.css" ${md} --to=html5 -s -f markdown+smart --metadata pagetitle="Ethereum.nix options" -o $out/index.html
  ''
