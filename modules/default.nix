{...}: {
  flake.nixosModules.default = {...}: {
    imports = [
      ./geth.nix
      ./prysm
      ./erigon.nix
    ];
  };
}
