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
      enable = mkEnableOption "Lighthouse Ethereum Validator Client written in Rust from Sigma Prime";

      package = mkOption {
        type = types.package;
        default = pkgs.lighthouse;
        defaultText = literalExpression "pkgs.lighthouse";
        description = "Package to use for Lighthouse binary.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services.";
      };

      user = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "User to run the systemd service.";
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = { };
        description = ''
          Lighthouse validator configuration options. These are converted to CLI arguments.
          Use flat dashed keys that match CLI flag names (e.g., "beacon-nodes", "suggested-fee-recipient").

          When beacon-nodes is not set, the module will automatically look up the HTTP address
          from a lighthouse-beacon service with the same instance name.
        '';
        example = literalExpression ''
          {
            network = "holesky";
            beacon-nodes = ["http://localhost:5052"];
            suggested-fee-recipient = "0x...";
            graffiti = "my-validator";
            http = true;
            "http-address" = "127.0.0.1";
            "http-port" = 5062;
            metrics = true;
            "metrics-address" = "127.0.0.1";
            "metrics-port" = 5064;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Lighthouse Validator Client.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.lighthouse-validator = mkOption {
    type = types.attrsOf (types.submodule validatorOpts);
    default = { };
    description = "Specification of one or more Lighthouse validator instances.";
  };
}
