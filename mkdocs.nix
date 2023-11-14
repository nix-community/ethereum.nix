{
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs) stdenv runCommand;

    my-mkdocs =
      runCommand "my-mkdocs" {
        buildInputs = [
          pkgs.python311
          pkgs.python311Packages.mkdocs
          pkgs.python311Packages.mkdocs-material
        ];
      } ''
        mkdir -p $out/bin

        cat <<MKDOCS > $out/bin/mkdocs
        #!${pkgs.runtimeShell}
        set -euo pipefail
        export PYTHONPATH=$PYTHONPATH
        exec ${pkgs.python311Packages.mkdocs}/bin/mkdocs "\$@"
        MKDOCS

        chmod +x $out/bin/mkdocs
      '';

    options-doc = let
      eachOptions = with lib;
        filterAttrs
        (_: hasSuffix "options.nix")
        (extras.flattenTree {tree = extras.rakeLeaves ./modules;});

      eachOptionsDoc = with lib;
        mapAttrs' (
          name: value:
            nameValuePair
            # take geth.options and turn it into just geth
            (head (splitString "." name))
            # generate options doc
            (pkgs.nixosOptionsDoc {options = evalModules {modules = [value];};})
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
      '';
    docsPath = "./docs/reference/module-options";
  in {
    packages.my-mkdocs = my-mkdocs;
    packages.docs = stdenv.mkDerivation {
      name = "ethereum-nix-docs";

      src = lib.cleanSourceWith {
        src = ./.;
        filter = path: type: let
          baseName = builtins.baseNameOf path;
          inDocs = builtins.match ".*/docs(/.*)?" path != null;
        in
          baseName == "mkdocs.yml" || inDocs;
      };

      buildInput = [options-doc];
      nativeBuildInputs = [my-mkdocs];

      buildPhase = ''
        ln -s ${options-doc} ${docsPath}
        mkdocs build
      '';

      installPhase = ''
        mv site $out
      '';

      passthru.serve = pkgs.writeShellScriptBin "serve" ''
        set -euo pipefail

        # link in options reference
        rm -f ${docsPath}
        ln -s ${options-doc} ${docsPath}

        ${my-mkdocs}/bin/mkdocs serve
      '';
    };

    devshells.default.commands = let
      category = "Docs";
    in [
      {
        inherit category;
        name = "docs-serve";
        help = "Serve docs";
        command = "nix run .#docs.serve";
      }
      {
        inherit category;
        name = "docs-build";
        help = "Build docs";
        command = "nix build .#docs";
      }
    ];
  };
}
