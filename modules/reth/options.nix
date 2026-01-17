{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  rethOpts = {
    options = {
      enable = mkEnableOption "Reth Ethereum Node";

      package = mkOption {
        type = types.package;
        default = pkgs.reth;
        defaultText = literalExpression "pkgs.reth";
        description = "Package to use as Reth node.";
      };

      subVolume = mkEnableOption "Use a subvolume for the state directory if the underlying filesystem supports it e.g. btrfs";

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
          Reth configuration. Converted to CLI arguments.

          Use flat dotted keys (e.g., "http.addr" not http.addr).
          Use http = true for --http flag.

          See https://reth.rs for available options.
        '';
        example = literalExpression ''
          {
            chain = "mainnet";
            http = true;
            "http.addr" = "0.0.0.0";
            "http.api" = ["eth" "net" "web3"];
            ws = true;
            "authrpc.jwtsecret" = "/var/run/reth/jwtsecret";
            metrics = "127.0.0.1:9001";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Reth.";
      };
    };
  };
in {
  options.services.ethereum.reth = mkOption {
    type = types.attrsOf (types.submodule rethOpts);
    default = {};
    description = "Specification of one or more Reth instances.";
  };
}
