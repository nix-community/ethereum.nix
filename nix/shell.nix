{
  perSystem = {
    lib,
    pkgs,
    config,
    inputs',
    ...
  }: let
    inherit (config.mission-control) installToDevShell;
    inherit (pkgs) mkShellNoCC;
    inherit (inputs'.nixpkgs-unstable.legacyPackages) nix-update statix mkdocs;
  in {
    devShells.default = installToDevShell (mkShellNoCC {
      name = "ethereum.nix";
      packages = [nix-update statix mkdocs pkgs.python310Packages.mkdocs-material];
    });
  };
}
