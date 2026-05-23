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
      enable = mkEnableOption "Nimbus, Nim implementation of the Ethereum Beacon Chain";

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
        description = "User to run the systemd service. Defaults to nimbus-beacon-<name>.";
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = { };
        description = ''
          Nimbus beacon node configuration options. These are converted to CLI arguments.
          Use flat dashed keys that match CLI flag names (e.g., "tcp-port", "rest-address").
        '';
        example = literalExpression ''
          {
            network = "mainnet";
            el = ["http://127.0.0.1:8551"];
            jwt-secret = "/var/run/nimbus/jwtsecret";
            tcp-port = 9000;
            udp-port = 9000;
            rest = true;
            rest-address = "127.0.0.1";
            rest-port = 5052;
            metrics = true;
            metrics-address = "127.0.0.1";
            metrics-port = 5054;
            doppelganger-detection = true;
            trusted-node-url = "https://checkpoint-sync.mainnet.ethpandaops.io";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Nimbus Beacon Chain.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.nimbus-beacon = mkOption {
    type = types.attrsOf (types.submodule beaconOpts);
    default = { };
    description = "Specification of one or more Nimbus beacon chain instances.";
  };
}
