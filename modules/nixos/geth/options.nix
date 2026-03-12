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

  gethOpts = {
    options = {
      enable = mkEnableOption "Go Ethereum Node";

      package = mkOption {
        type = types.package;
        default = pkgs.geth;
        defaultText = literalExpression "pkgs.geth";
        description = "Package to use as Go Ethereum node.";
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
        default = { };
        description = ''
          Geth configuration options. These are converted to CLI arguments.
          Use flat dotted keys that match CLI flag names (e.g., "http.addr" not nested http.addr).
        '';
        example = literalExpression ''
          {
            sepolia = true;
            http = true;
            "http.addr" = "0.0.0.0";
            "http.port" = 8545;
            "http.api" = ["eth" "net" "web3"];
            "authrpc.jwtsecret" = "/var/run/geth/jwtsecret";
            syncmode = "snap";
            gcmode = "full";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Go Ethereum.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.geth = mkOption {
    type = types.attrsOf (types.submodule gethOpts);
    default = { };
    description = "Specification of one or more geth instances.";
  };
}
