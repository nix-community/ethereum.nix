{
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs) stdenv mkdocs python310Packages nixVersions;

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

    # TODO: Upstream this to nixpkgs
    mkdocs-nixos-options = with pkgs.python3Packages;
      buildPythonPackage rec {
        pname = "mkdocs-nixos-options";
        version = "0.1.0";

        format = "pyproject";

        src = pkgs.fetchFromGitHub {
          owner = "aldoborrero";
          repo = pname;
          rev = "2b0a3863eb1acfe85eeb9326e4f0c8b504aa87d7";
          hash = "sha256-ewKg2pnlKGbBNjh/+FqfAB3mC9GDbOqVEfMei+63SiU=";
        };

        nativeBuildInputs = [
          poetry-core
        ];

        propagatedBuildInputs = [
          mkdocs
        ];

        doCheck = false;

        pythonImportsCheck = ["mkdocs_nixos_options"];
      };

    my-mkdocs =
      pkgs.runCommand "my-mkdocs"
      {
        nativeBuildInputs = [
          mkdocs
          mkdocs-nixos-options
          mkdocs-plugins
          python310Packages.mkdocs-material
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
  in {
    packages.docs = stdenv.mkDerivation {
      name = "ethereum-nix-docs";

      src = lib.cleanSource ./.;

      nativeBuildInputs = [my-mkdocs];

      propagatedBuildInputs = [
        nixVersions.nix_2_15
      ];

      buildPhase = ''
        mkdocs build
      '';

      installPhase = ''
        mv site $out
      '';

      passthru.serve = pkgs.writeShellScriptBin "serve" ''
        set -euo pipefail

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
