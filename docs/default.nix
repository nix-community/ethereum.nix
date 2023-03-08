{
  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    packages.docs-options = pkgs.callPackage ./options.nix {inherit lib;};
  };
}
