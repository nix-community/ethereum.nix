{
  perSystem = {
    lib,
    pkgs,
    config,
    inputs',
    ...
  }: let
    inherit (pkgs) mkShellNoCC;
    inherit (inputs'.nixpkgs-unstable.legacyPackages) nix-update statix mkdocs;
  in {
    devShells.default = mkShellNoCC {
      name = "ethereum.nix";
      inputsFrom = [config.mission-control.devShell];
      packages = [
        nix-update
        statix
        mkdocs
        pkgs.python310Packages.mkdocs-material
      ];
    };
  };
}
