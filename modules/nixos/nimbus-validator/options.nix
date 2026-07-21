{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    literalExpression
    ;

  validatorOpts = {
    options = {
      enable = mkEnableOption "Nimbus validator client";

      package = mkOption {
        type = types.package;
        default = pkgs.nimbus;
        defaultText = literalExpression "pkgs.nimbus";
        description = "Package to use for Nimbus binary.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services.";
      };

      user = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "User to run the systemd service. Defaults to nimbus-validator-<name>.";
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = { };
        description = ''
          Nimbus validator client configuration options. These are converted to CLI arguments.
          Use flat dashed keys that match CLI flag names (e.g., "beacon-node", "rest-port").
        '';
        example = literalExpression ''
          {
            network = "mainnet";
            beacon-node = [ "http://127.0.0.1:5052" ];
            metrics = true;
            metrics-address = "127.0.0.1";
            metrics-port = 8008;
            keymanager = true;
            keymanager-address = "127.0.0.1";
            keymanager-port = 5053;
            doppelganger-detection = true;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Nimbus validator client.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.nimbus-validator = mkOption {
    type = types.attrsOf (types.submodule validatorOpts);
    default = { };
    description = "Specification of one or more Nimbus validator client instances.";
  };
}
