{
  perSystem = {inputs', ...}: let
    inherit (inputs'.nixpkgs-unstable.legacyPackages) nix-update statix;
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
