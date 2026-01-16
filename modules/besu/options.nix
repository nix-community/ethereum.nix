{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  besuOpts = {
    options = {
      enable = mkEnableOption "Besu Execution Client";

      subVolume = mkEnableOption "Use a subvolume for the state directory if the underlying filesystem supports it e.g. btrfs";

      package = mkOption {
        type = types.package;
        default = pkgs.besu;
        defaultText = literalExpression "pkgs.besu";
        description = "Package that will provide the Besu binary.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services.";
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = {};
        description = ''
          Besu configuration. Converted to CLI arguments.

          Use Besu's actual flag names (e.g., rpc-http-enabled, not http.enable).
          All options passed as --option-name=value.

          See https://besu.hyperledger.org for available options.
        '';
        example = literalExpression ''
          {
            network = "mainnet";
            p2p-port = 30303;
            rpc-http-enabled = true;
            rpc-http-host = "127.0.0.1";
            rpc-http-port = 8545;
            rpc-http-api = ["ETH" "NET" "WEB3"];
            rpc-http-cors-origins = ["*"];
            engine-rpc-enabled = true;
            engine-rpc-port = 8551;
            engine-jwt-secret = "/var/run/besu/jwtsecret";
            metrics-enabled = true;
            metrics-host = "127.0.0.1";
            metrics-port = 9545;
            logging = "INFO";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Besu.";
      };
    };
  };
in {
  options.services.ethereum.besu = mkOption {
    type = types.attrsOf (types.submodule besuOpts);
    default = {};
    description = "Specification of one or more Besu instances.";
  };
}
