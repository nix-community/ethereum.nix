{
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    inherit (inputs'.nixpkgs-unstable.legacyPackages) nix-update statix mkdocs;
  in {
    devshells.default = {
      name = "ethereum.nix";
      packages = [
        nix-update
        statix
      ];
    };
  };
}
