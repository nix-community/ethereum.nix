{
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs) stdenv mkdocs python310Packages;

    my-mkdocs =
      pkgs.runCommand "my-mkdocs"
      {
        buildInputs = [
          mkdocs
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

    options-doc = pkgs.callPackage ./options-doc.nix {inherit lib;};
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
