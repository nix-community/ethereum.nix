{
  imports = [
    ./testing.nix
  ];

  # create a default nixos module which mixes in all modules
  flake.nixosModules.default = {
    imports = [
      ./backup
      ./erigon
      ./geth
      ./geth-bootnode
      ./lighthouse-beacon
      ./mev-boost
      ./nethermind
      ./prysm-beacon
      ./prysm-validator
      ./restore
    ];
  };
}
