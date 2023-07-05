{
  perSystem = {
    lib,
    pkgs,
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
      name = "ethereum-nix-docs";

      src = lib.cleanSource ./.;

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
        name = "docs";
        help = "Build and watch for docs";
        command = ''
          Help() {
            echo "  Ethereum.nix Docs"
            echo
            echo "  Usage:"
            echo "    docs build"
            echo "    docs serve"
            echo
            echo "  Options:"
            echo "    -h --help          Show this screen."
            echo
          }

          Build() {
            nix build .#docs
          }

          Serve() {
            nix run .#docs.serve
          }

          ARGS=$(getopt --options h --longoptions help -- "$@")

          while [ $# -gt 0 ]; do
            case "$1" in
                build) Build; exit 0;;
                serve) Build; Serve; exit 0;;
                -h | --help) Help; exit 0;;
                -- ) shift; break;;
                * ) break;;
            esac
          done

          if [ $# -eq 0 ]; then
            # No test name has been provided
            Help
            exit 1
          fi
        '';
      }
    ];
  };
}
