{
  lib,
  pkgs,
  ...
}: let
  args = import ./args.nix lib;

  nimbusOpts = with lib; {
    options = {
      enable = mkEnableOption "Nimbus Ethereum Node.";

      package = mkOption {
        type = types.package;
        default = pkgs.nimbus;
        defaultText = literalExpression "pkgs.nimbus";
        description = "Package to use as Nimbus.";
      };

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Nimbus.";
        default = [];
      };

      user = mkOption {
        type = types.nullOr types.str;
        description = "Service user";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services";
      };
    };
  };
in {
  options.services.ethereum.nimbus = with lib;
    mkOption {
      type = types.attrsOf (types.submodule nimbusOpts);
      default = {};
      description = "Specification of one or more Nimbus instances.";
    };
}
