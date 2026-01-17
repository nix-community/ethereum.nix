{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  nimbusValidatorOpts = {
    options = {
      enable = mkEnableOption "Nimbus Validator Client";

      package = mkOption {
        type = types.package;
        default = pkgs.nimbus;
        defaultText = literalExpression "pkgs.nimbus";
        description = "Package to use as Nimbus Validator Client.";
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = {};
        description = ''
          Nimbus Validator configuration. Converted to CLI arguments.

          Use network to select the binary (mainnet vs gnosis).
          All options passed as --option-name=value.

          See https://nimbus.guide for available options.
        '';
        example = literalExpression ''
          {
            network = "mainnet";
            data-dir = "/var/lib/nimbus-validator";
            beacon-node = ["http://127.0.0.1:5052"];
            graffiti = "my-validator";
            suggested-fee-recipient = "0x...";
            metrics = true;
            metrics-address = "127.0.0.1";
            metrics-port = 8108;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Nimbus Validator Client.";
      };
    };
  };
in {
  options.services.ethereum.nimbus-validator = mkOption {
    type = types.attrsOf (types.submodule nimbusValidatorOpts);
    default = {};
    description = "Specification of one or more Nimbus Validator Client instances.";
  };
}
