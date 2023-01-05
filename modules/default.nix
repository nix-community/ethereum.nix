{...}: {
  flake.nixosModules.default = {...}: {
    imports = [
      ./geth.nix
      ./prysm
    ];
  };
}
