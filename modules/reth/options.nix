{
  lib,
  pkgs,
  ...
}: let
  args = import ./args.nix lib;

  rethOpts = with lib; {
    options = {
      enable = mkEnableOption "Reth Ethereum Node.";

      subVolume = mkEnableOption "Use a subvolume for the state directory if the underlying filesystem supports it e.g. btrfs";

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Reth.";
        default = [];
      };

      package = mkOption {
        type = types.package;
        default = pkgs.reth;
        defaultText = literalExpression "pkgs.reth";
        description = "Package to use as Reth node.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services";
      };
    };
  };
in {
  options.services.ethereum.reth = with lib;
    mkOption {
      type = types.attrsOf (types.submodule rethOpts);
      default = {};
      description = "Specification of one or more Reth instances.";
    };
}
