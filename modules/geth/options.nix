{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

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
        default = {};
        description = ''
          Geth configuration. Converted to CLI arguments.

          Use flat dotted keys (e.g., "http.addr" not http.addr).
          Use http = true for --http flag.
          Use sepolia/holesky/hoodi = true for network selection.

          See https://geth.ethereum.org/docs for available options.
        '';
        example = literalExpression ''
          {
            sepolia = true;
            http = true;
            "http.addr" = "0.0.0.0";
            "http.api" = ["eth" "net" "web3"];
            ws = true;
            "authrpc.jwtsecret" = "/var/run/geth/jwtsecret";
            metrics = true;
            "metrics.addr" = "127.0.0.1";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Go Ethereum.";
      };

      # mixin backup options
      backup = let
        inherit (import ../backup/lib.nix lib) options;
      in
        options;

      # mixin restore options
      restore = let
        inherit (import ../restore/lib.nix lib) options;
      in
        options;
    };
  };
in {
  options.services.ethereum.geth = mkOption {
    type = types.attrsOf (types.submodule gethOpts);
    default = {};
    description = "Specification of one or more geth instances.";
  };
}
