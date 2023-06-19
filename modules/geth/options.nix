{
  lib,
  pkgs,
  ...
}: with lib; let
  args = import ./args.nix lib;

  gethOpts = {
    options = rec {
      enable = mkEnableOption "Go Ethereum Node.";

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Go Ethereum.";
        default = [];
      };

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
  options.services.ethereum.geth =
    mkOption {
      type = with types; attrsOf (submodule gethOpts);
      default = {};
      description = "Specification of one or more geth instances.";
    };
}
