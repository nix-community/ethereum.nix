{
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    mkdocs = lib.getExe pkgs.mkdocs;
    reference-doc = pkgs.callPackage ./reference.nix {inherit lib;};
    src = ../.;
  in {
    packages.docs =
      pkgs.runCommand "docs.html"
      {
        nativeBuildInputs = [pkgs.python310Packages.mkdocs-material];
      } ''
        mkdir $out
        src=$(mktemp -d)
        cp -R ${src}/* $src/
        chmod -R u+w $src
        cd $src
        ls -al ./.
        # link in options reference
        ln -s ${reference-doc} ./docs/reference.md
        ${mkdocs} build -d $out
      '';

    mission-control.scripts = with lib; {
      serve-docs = {
        category = "Docs";
        description = "Serve the docs";
        exec = ''
          # link in options reference
          rm -f ./docs/reference.md
          ln -s ${reference-doc} ./docs/reference.md


          ${mkdocs} serve
        '';
      };
    };
  };
}
