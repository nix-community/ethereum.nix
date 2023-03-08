{
  lib,
  pkgs,
  ...
}: let
  args = import ./args.nix lib;

  bootnodeOpts = with lib; {
    options = with lib; rec {
      enable = mkEnableOption (mdDoc "Go Ethereum Boot Node");

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = mdDoc "Additional arguments to pass to the Go Ethereum Bootnode.";
        default = [];
      };

      package = mkOption {
        type = types.package;
        default = pkgs.geth;
        defaultText = literalExpression "pkgs.geth";
        description = mdDoc "Package to use as Go Ethereum Boot node.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for any enabled networking services";
      };
    };
  };
in {
  options.services.ethereum.geth-bootnode = with lib;
    mkOption {
      type = types.attrsOf (types.submodule bootnodeOpts);
      default = {};
      description = mdDoc "Specification of one or more geth bootnode instances.";
    };
}
