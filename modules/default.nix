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
      ./lighthouse-beacon
      ./lighthouse-validator
      ./mev-boost
      ./nethermind
      ./nimbus-beacon
      ./prysm
      ./prysm-validator
      ./restore
      ./reth
      ./nimbus-validator
      ./teku-beacon
    ];
  };
}
