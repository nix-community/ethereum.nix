{
  perSystem = {
    pkgs,
    pkgsUnstable,
    ...
  }: {
    devshells.default = {
      name = "ethereum.nix";
      packages = with pkgsUnstable; [
        nix-update
        statix
        mkdocs
        pkgs.python310Packages.mkdocs-material
      ];
    };
  };
}
