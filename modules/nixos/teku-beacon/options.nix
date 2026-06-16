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
      enable = mkEnableOption "Teku Beacon Node";

      package = mkOption {
        type = types.package;
        default = pkgs.teku;
        defaultText = literalExpression "pkgs.teku";
        description = "Package to use as Teku binary.";
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
          Teku configuration options. These are converted to CLI arguments.
          Use flat dashed keys that match CLI flag names (e.g., "rest-api-interface" not nested rest-api.interface).
        '';
        example = literalExpression ''
          {
            network = "mainnet";
            ee-endpoint = "http://127.0.0.1:8551";
            ee-jwt-secret-file = "/var/run/teku/jwtsecret";
            p2p-port = 9000;
            rest-api-enabled = true;
            rest-api-interface = "127.0.0.1";
            rest-api-port = 5051;
            metrics-enabled = true;
            metrics-interface = "127.0.0.1";
            metrics-port = 8008;
            data-storage-mode = "minimal";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Teku Beacon Chain.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.teku-beacon = mkOption {
    type = types.attrsOf (types.submodule beaconOpts);
    default = { };
    description = "Specification of one or more Teku beacon chain instances.";
  };
}
