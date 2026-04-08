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

  beaconOpts = {
    options = {
      enable = mkEnableOption "Lighthouse Ethereum Beacon Chain Node written in Rust from Sigma Prime";

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
          Lighthouse beacon configuration options. These are converted to CLI arguments.
          Use dashed keys that match CLI flag names (e.g., "discovery-port", "execution-endpoint").
        '';
        example = literalExpression ''
          {
            network = "mainnet";
            execution-endpoint = "http://127.0.0.1:8551";
            execution-jwt = "/var/run/lighthouse/jwtsecret";
            checkpoint-sync-url = "https://mainnet.checkpoint.sigp.io";
            discovery-port = 9000;
            quic-port = 9001;
            http = true;
            http-address = "127.0.0.1";
            http-port = 5052;
            metrics = true;
            metrics-address = "127.0.0.1";
            metrics-port = 5054;
            disable-upnp = true;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Lighthouse Beacon Chain.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.lighthouse-beacon = mkOption {
    type = types.attrsOf (types.submodule beaconOpts);
    default = { };
    description = "Specification of one or more lighthouse beacon chain instances.";
  };
}
