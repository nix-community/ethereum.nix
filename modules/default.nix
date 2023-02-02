{lib, ...}: {
  flake.nixosModules.default = {
    imports = [
      ./clients
      ./snapshot.nix
    ];
  };
}
