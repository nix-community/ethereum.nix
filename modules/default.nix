{
  imports = [
    ./testing.nix
  ];

  # create a default nixos module which mixes in all modules
  flake.nixosModules.default = {
    imports = [
      ./backup
      ./besu
      ./erigon
      ./geth
      ./geth-bootnode
      ./lighthouse
      ./lighthouse-validator
      ./mev-boost
      ./nethermind
      ./nimbus
      ./prysm
      ./prysm-validator
      ./restore
      ./reth
      ./nimbus-validator
      ./teku
    ];
  };
}
