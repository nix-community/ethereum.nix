{
  perSystem = {
    pkgs,
    config,
    inputs',
    ...
  }: let
    inherit (config.mission-control) installToDevShell;
    inherit (pkgs) mkShellNoCC;
    inherit (inputs'.nixpkgs-unstable.legacyPackages) nix-update statix;
  in {
    devShells.default = installToDevShell (mkShellNoCC {
      name = "ethereum.nix";
      packages = [nix-update statix];
    });
  };
}
