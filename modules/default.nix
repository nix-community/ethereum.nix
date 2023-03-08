{
  imports = [
    ./testing.nix
  ];

  # create a default nixos module which mixes in all modules
  flake.nixosModules.default = {
    imports = [
      ./backup
      ./restore
      ./geth
      ./nethermind
      ./erigon
      ./prysm-beacon
    ];
  };
}
