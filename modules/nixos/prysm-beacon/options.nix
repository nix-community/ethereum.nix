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
      enable = mkEnableOption "Ethereum Beacon Chain Node from Prysmatic Labs";

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
          Prysm Beacon Chain configuration options. These are converted to CLI arguments.
          Use dashed keys that match CLI flag names (e.g., "grpc-gateway-host").
          Network flags (holesky, sepolia, hoodi) become just --<network>.
        '';
        example = literalExpression ''
          {
            sepolia = true;
            jwt-secret = "/var/run/prysm/jwtsecret";
            checkpoint-sync-url = "https://checkpoint-sync.sepolia.ethpandaops.io";
            genesis-beacon-api-url = "https://checkpoint-sync.sepolia.ethpandaops.io";
            p2p-udp-port = 12000;
            p2p-tcp-port = 13000;
            grpc-gateway-host = "0.0.0.0";
            grpc-gateway-port = 3500;
            rpc-host = "127.0.0.1";
            rpc-port = 4000;
            monitoring-host = "127.0.0.1";
            monitoring-port = 8080;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Prysm Beacon Chain.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.prysm-beacon = mkOption {
    type = types.attrsOf (types.submodule beaconOpts);
    default = { };
    description = "Specification of one or more prysm beacon chain instances.";
  };
}
