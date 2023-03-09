{
  perSystem = {
    lib,
    pkgs,
    self',
    ...
  }: let
    inherit (pkgs) stdenv mkdocs python310Packages;
    reference-doc = pkgs.callPackage ./reference.nix {inherit lib;};
  in {
    packages.docs = stdenv.mkDerivation {
      src = ./.;
      name = "ethereum-nix-docs";

      buildInput = [reference-doc];
      nativeBuildInputs = [mkdocs python310Packages.mkdocs-material];

      buildPhase = ''
        ln -s ${reference-doc} ./docs/modules/reference.md
        mkdocs build
      '';

      installPhase = ''
        mv site $out
      '';
    };

    apps.deploy-docs = let
      script = pkgs.writeShellScriptBin "deploy-docs" ''
        git checkout gh-pages
        rm -rf ./*
        cp -r ${self'.packages.docs} ./
        git add .
        git commit -m "update - $(date --rfc-3339=seconds)"
        git push
      '';
    in {
      type = "app";
      program = "${script}/bin/deploy-docs";
    };

    mission-control.scripts = let
      category = "Docs";
    in
      with lib; {
        docs = {
          inherit category;
          description = "Serve docs";
          exec = ''
            # link in options reference
            rm -f ./docs/modules/reference.md
            ln -s ${reference-doc} ./docs/modules/reference.md

            mkdocs serve
          '';
        };
      };
  };
}
