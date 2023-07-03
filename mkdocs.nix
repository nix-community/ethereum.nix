{
  perSystem = {
    lib,
    pkgs,
    self',
    ...
  }: let
    inherit (pkgs) stdenv mkdocs python310Packages;

    # TODO: Upstream this to nixpkgs
    essentials = with pkgs.python3Packages;
      buildPythonPackage rec {
        pname = "essentials";
        version = "1.1.5";

        src = pkgs.fetchFromGitHub {
          owner = "Neoteroi";
          repo = pname;
          rev = "v${version}";
          hash = "sha256-WMHjBVkeSoQ4Naj1U7Bg9j2hcoErH1dx00BPKiom9T4=";
        };

        doCheck = false;
      };

    # TODO: Upstream this to nixpkgs
    essentials-openapi = with pkgs.python3Packages;
      buildPythonPackage rec {
        pname = "essentials-openapi";
        version = "1.0.7";

        format = "pyproject";

        src = pkgs.fetchFromGitHub {
          owner = "Neoteroi";
          repo = pname;
          rev = "v${version}";
          hash = "sha256-j0vEMNXZ9TrcFx8iIyTFQIwF49LEincLmnAt+qodYmA=";
        };

        nativeBuildInputs = [
          hatchling
          pyyaml
        ];

        propagatedBuildInputs = [
          essentials
        ];

        doCheck = false;

        pythonImportsCheck = ["openapidocs"];
      };

    # TODO: Upstream this to nixpkgs
    mkdocs-plugins = with pkgs.python3Packages;
      buildPythonPackage rec {
        pname = "mkdocs-plugins";
        version = "1.0.2";

        format = "pyproject";

        src = pkgs.fetchFromGitHub {
          owner = "Neoteroi";
          repo = pname;
          rev = "v${version}";
          hash = "sha256-C/HOqti8s/+V9scbS/Ch0i4sSFvRMF/K5+b6qzgTFSc=";
        };

        buildInputs = [
          essentials-openapi
          rich
        ];

        nativeBuildInputs = [
          hatchling
        ];

        propagatedBuildInputs = [
          httpx
          mkdocs
        ];

        doCheck = false;

        pythonImportsCheck = ["neoteroi.mkdocs"];
      };

    my-mkdocs =
      pkgs.runCommand "my-mkdocs"
      {
        buildInputs = [
          mkdocs
          python310Packages.mkdocs-material
          mkdocs-plugins
        ];
      } ''
        mkdir -p $out/bin

        cat <<MKDOCS > $out/bin/mkdocs
        #!${pkgs.bash}/bin/bash
        set -euo pipefail
        export PYTHONPATH=$PYTHONPATH
        exec ${mkdocs}/bin/mkdocs "\$@"
        MKDOCS

        chmod +x $out/bin/mkdocs
      '';

    options-doc = let
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
      pkgs.runCommand "nixos-options" {} ''
        mkdir $out
        ${statements}
      '';
    docsPath = "./docs/reference/module-options";
  in {
    packages.docs = stdenv.mkDerivation {
      src = ./.;
      name = "ethereum-nix-docs";

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
