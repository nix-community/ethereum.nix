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

  bootnodeOpts = {
    options = {
      enable = mkEnableOption "Go Ethereum Boot Node";

      package = mkOption {
        type = types.package;
        default = pkgs.geth;
        defaultText = literalExpression "pkgs.geth";
        description = "Package to use as Go Ethereum Boot node.";
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
          Bootnode configuration options. These are converted to CLI arguments.
          Note: bootnode uses single-dash flags (e.g., -addr not --addr).
        '';
        example = literalExpression ''
          {
            addr = ":30301";
            nat = "none";
            nodekey = "/var/lib/geth-bootnode/nodekey";
            verbosity = 3;
            v5 = true;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to the Go Ethereum Bootnode.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.geth-bootnode = mkOption {
    type = types.attrsOf (types.submodule bootnodeOpts);
    default = { };
    description = "Specification of one or more geth bootnode instances.";
  };
}
