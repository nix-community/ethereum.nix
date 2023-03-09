{
  perSystem = {
    lib,
    pkgs,
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
        ln -s ${reference-doc} ./docs/reference.md
        ls -al ./docs
        cat ./docs/modules/reference.md
        mkdocs build
      '';

      installPhase = ''
        mv site $out
      '';
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
