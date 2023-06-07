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
      ./geth-bootnode
      ./nethermind
      ./erigon
      ./prysm-beacon
      ./mev-boost
    ];
  };
}
