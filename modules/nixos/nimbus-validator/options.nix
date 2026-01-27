{
  lib,
  pkgs,
  ...
}:
let
  nimbusValidatorOpts = with lib; {
    options = {
      enable = mkEnableOption "Nimbus Validator Client.";

      package = mkOption {
        type = types.package;
        default = pkgs.nimbus;
        defaultText = literalExpression "pkgs.nimbus";
        description = "Package to use as Nimbus Validator Client.";
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Nimbus Validator Client.";
        default = [ ];
      };

      user = mkOption {
        type = types.nullOr types.str;
        description = "Service user";
      };

      network = mkOption {
        type = types.enum [
          "mainnet"
          "prater"
          "sepolia"
          "holesky"
          "gnosis"
          "chiado"
          "hoodi"
        ];
        default = "mainnet";
        description = "The Eth2 network to join";
      };
    };
  };
in
{
  options.services.ethereum.nimbus-validator =
    with lib;
    mkOption {
      type = types.attrsOf (types.submodule nimbusValidatorOpts);
      default = { };
      description = "Specification of one or more Nimbus Validator Client instances.";
    };
}
