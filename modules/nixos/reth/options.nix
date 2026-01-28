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

  rethOpts = {
    options = {
      enable = mkEnableOption "Reth Ethereum Node";

      package = mkOption {
        type = types.package;
        default = pkgs.reth;
        defaultText = literalExpression "pkgs.reth";
        description = "Package to use as Reth node.";
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
          Reth configuration options. These are converted to CLI arguments.
          Use flat dotted keys that match CLI flag names (e.g., "http.addr" not nested http.addr).

          Note: metrics uses addr:port format, so set "metrics" to "addr:port" string.
        '';
        example = literalExpression ''
          {
            chain = "mainnet";
            http = true;
            "http.addr" = "0.0.0.0";
            "http.port" = 8545;
            "http.api" = ["eth" "net" "web3"];
            ws = true;
            "ws.addr" = "127.0.0.1";
            "ws.port" = 8546;
            "authrpc.jwtsecret" = "/var/run/reth/jwtsecret";
            metrics = "127.0.0.1:6060";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Reth.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.reth = mkOption {
    type = types.attrsOf (types.submodule rethOpts);
    default = { };
    description = "Specification of one or more Reth instances.";
  };
}
