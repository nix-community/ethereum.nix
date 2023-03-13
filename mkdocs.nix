{
  perSystem = {
    lib,
    pkgs,
    self',
    ...
  }: let
    inherit (pkgs) stdenv mkdocs python310Packages;
    options-doc = pkgs.callPackage ./options-doc.nix {inherit lib;};
    docsPath = "./docs/reference/module-options";
  in {
    packages.docs = stdenv.mkDerivation {
      src = ./.;
      name = "ethereum-nix-docs";

      buildInput = [options-doc];
      nativeBuildInputs = [
        mkdocs
        python310Packages.mkdocs-material
        python310Packages.pygments
      ];

      buildPhase = ''
        ln -s ${options-doc} ${docsPath}
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
            rm -f ${docsPath}
            ln -s ${options-doc} ${docsPath}
            mkdocs serve
          '';
        };
      };
  };
}
