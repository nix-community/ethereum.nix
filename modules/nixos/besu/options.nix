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

  besuOpts = {
    options = {
      enable = mkEnableOption "Besu Ethereum Execution Client";

      package = mkOption {
        type = types.package;
        default = pkgs.besu;
        defaultText = literalExpression "pkgs.besu";
        description = "Package to use as Besu node.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services.";
      };

      subVolume = mkEnableOption "Use a subvolume for the state directory if the underlying filesystem supports it e.g. btrfs";

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = { };
        description = ''
          Besu configuration options. These are converted to CLI arguments.
          Use flat keys that match CLI flag names (e.g., "rpc-http-host" not nested rpc.http.host).
        '';
        example = literalExpression ''
          {
            network = "mainnet";
            logging = "INFO";
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
            metrics-port = 6060;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Besu.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.besu = mkOption {
    type = types.attrsOf (types.submodule besuOpts);
    default = { };
    description = "Specification of one or more Besu instances.";
  };
}
