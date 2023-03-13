{
  perSystem = {
    lib,
    pkgs,
    self',
    ...
  }: let
    inherit (pkgs) stdenv mkdocs python310Packages;
    options-doc = pkgs.callPackage ./options-doc.nix {inherit lib;};
  in {
    packages.docs = stdenv.mkDerivation {
      src = ./.;
      name = "ethereum-nix-docs";

      buildInput = [options-doc];
      nativeBuildInputs = [mkdocs python310Packages.mkdocs-material];

      buildPhase = ''
        ln -s ${options-doc} ./docs/reference/options.md
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
            rm -f ./docs/reference/options.md
            ln -s ${options-doc} ./docs/reference/options.md

            mkdocs serve
          '';
        };
      };
  };
}
