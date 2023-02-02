{lib, ...}: {
  flake.nixosModules.default = {
    imports = [
      ./clients
    ];
  };
}
