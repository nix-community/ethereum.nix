{
  perSystem = {
    lib,
    pkgs,
    self',
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

        mkdocs serve
      '';
    };

    mission-control.scripts = let
      category = "Docs";
    in
      with lib; {
        docs-serve = {
          inherit category;
          description = "Serve docs";
          exec = "nix run .#docs.serve";
        };
        docs-build = {
          inherit category;
          description = "Build docs";
          exec = "nix build .#docs";
        };
      };
  };
}
