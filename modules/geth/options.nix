{
  lib,
  pkgs,
  ...
}: let
  args = import ./args.nix lib;

  gethOpts = with lib; {
    options = rec {
      enable = mkEnableOption (mdDoc "Go Ethereum Node");

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = mdDoc "Additional arguments to pass to Go Ethereum.";
        default = [];
      };

      package = mkOption {
        type = types.package;
        default = pkgs.geth;
        defaultText = literalExpression "pkgs.geth";
        description = mdDoc "Package to use as Go Ethereum node.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for any enabled networking services";
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
  options.services.ethereum.geth = with lib;
    mkOption {
      type = types.attrsOf (types.submodule gethOpts);
      default = {};
      description = mdDoc "Specification of one or more geth instances.";
    };
}
