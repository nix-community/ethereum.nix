_localFlake: {...}: {
  flake.flakeModule.devnet = import ./devnet/flake-module.nix;

  # TODO: Mmmmmm, can't apply ${name} here as it's toplevel
  # flake.flakeModule.devnet = {
  #   pkgs,
  #   name,
  #   ...
  # }: {
  #   imports = [./devnet/flake-module.nix];

  #   devnet.${name}.anvil.program = withSystem pkgs.stdenv.hostPlatform.system (
  #     {config, ...}:
  #       config.packages.foundry
  #   );
  # };
}
