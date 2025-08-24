{
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs) stdenv runCommand;
  in {
    packages.docs = let
      mkdocs-custom =
        pkgs.runCommand "mkdocs-custom" {
          buildInputs = [
            pkgs.python312
            pkgs.python312Packages.mkdocs
            pkgs.python312Packages.mkdocs-material
            pkgs.python312Packages.neoteroi-mkdocs
          ];
          meta.mainProgram = "mkdocs";
        } ''
          mkdir -p $out/bin

          cat <<MKDOCS > $out/bin/mkdocs
          #!${pkgs.runtimeShell}
          set -euo pipefail
          export PYTHONPATH=$PYTHONPATH
          exec ${pkgs.python312Packages.mkdocs}/bin/mkdocs "\$@"
          MKDOCS

          chmod +x $out/bin/mkdocs
        '';
      docsPath = "./docs/nixos/modules";
      nixosMarkdownDocs = runCommand "nixos-options" {} ''
        mkdir $out
        ${lib.mkdocs.createNixosMarkdownDocs {modulesPath = ./modules;}}
      '';
    in
      stdenv.mkDerivation {
        name = "ethereum-nix-docs";

        src = lib.cleanSourceWith {
          src = ./.;
          filter = path: _type: let
            file = builtins.baseNameOf path;
            inDocsFolder = builtins.match ".*/docs(/.*)?" path != null;
          in
            file == "mkdocs.yml" || inDocsFolder;
        };

        buildInput = [nixosMarkdownDocs];
        nativeBuildInputs = [mkdocs-custom];

        preBuild = ''
          # create link to nixos markdown options reference
          mkdir -p ${docsPath}
          ln -sf ${nixosMarkdownDocs}/* ${docsPath}/
        '';

        buildPhase = ''
          runHook preBuild
          mkdocs build
        '';

        installPhase = ''
          mv site $out
        '';

        passthru.serve = pkgs.writeShellScriptBin "serve" ''
          set -euo pipefail

          # create link to nixos markdown options reference
          rm -f ${docsPath}/*.md
          ln -sf ${nixosMarkdownDocs}/* ${docsPath}/

          ${lib.getExe mkdocs-custom} serve
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
                serve) Serve; exit 0;;
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
