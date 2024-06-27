{
  lib,
  pkgs,
  ...
}: let
  args = import ./args.nix lib;

  validatorOpts = with lib; {
    options = {
      enable = mkEnableOption "Ethereum Prysm validator client";

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Prysm validator.";
        default = [];
      };

      package = mkOption {
        default = pkgs.prysm;
        defaultText = literalExpression "pkgs.prysm";
        type = types.package;
        description = "Package to use for Prysm binary";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services";
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
  options.services.ethereum.prysm-validator = with lib;
    mkOption {
      type = types.attrsOf (types.submodule validatorOpts);
      default = {};
      description = "Specification of one or more prysm validator instances.";
    };
}
