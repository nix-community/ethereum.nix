{
  lib,
  pkgs,
  ...
}: let
  args = import ./args.nix lib;

  besuOpts = with lib; {
    options = {
      enable = mkEnableOption "Besu Execution Client";
      subVolume = mkEnableOption "Use a subvolume for the state directory if the underlying filesystem supports it e.g. btrfs";

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Besu";
        default = [];
      };

      package = mkOption {
        type = types.package;
        default = pkgs.besu;
        defaultText = literalExpression "pkgs.besu";
        description = "Package that will provide the Besu binary";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services";
      };
    };
  };
in {
  options.services.ethereum.besu = with lib;
    mkOption {
      type = types.attrsOf (types.submodule besuOpts);
      default = {};
      description = "Specification of one or more Besu instances.";
    };
}
