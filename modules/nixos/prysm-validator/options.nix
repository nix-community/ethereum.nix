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
      enable = mkEnableOption "Ethereum Prysm validator client";

      package = mkOption {
        type = types.package;
        default = pkgs.prysm;
        defaultText = literalExpression "pkgs.prysm";
        description = "Package to use for Prysm binary.";
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
          Prysm validator configuration options. These are converted to CLI arguments.
          Use dashed keys that match CLI flag names (e.g., "wallet-dir", "monitoring-port").
          Network is specified as a boolean (e.g., holesky = true becomes --holesky).
        '';
        example = literalExpression ''
          {
            holesky = true;
            wallet-dir = "/var/lib/prysm/wallet";
            wallet-password-file = "/run/secrets/wallet-password";
            suggested-fee-recipient = "0x...";
            graffiti = "my-validator";
            monitoring-host = "127.0.0.1";
            monitoring-port = 8081;
            grpc-gateway-host = "127.0.0.1";
            grpc-gateway-port = 7500;
            rpc = true;
            rpc-host = "127.0.0.1";
            rpc-port = 7000;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Prysm validator.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.prysm-validator = mkOption {
    type = types.attrsOf (types.submodule validatorOpts);
    default = { };
    description = "Specification of one or more prysm validator instances.";
  };
}
