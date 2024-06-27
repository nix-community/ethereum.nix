{
  lib,
  pkgs,
  ...
}:
with lib; let
  validatorOpts = {name, ...}: {
    options = {
      enable = mkEnableOption "Lighthouse Ethereum Validator Client written in Rust from Sigma Prime";

      args = import ./args.nix {inherit lib name;};

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Lighthouse Validator Client.";
        default = [];
      };

      package = mkOption {
        default = pkgs.lighthouse;
        defaultText = literalExpression "pkgs.lighthouse";
        type = types.package;
        description = "Package to use for Lighthouse binary";
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
  options.services.ethereum.lighthouse-validator = mkOption {
    type = types.attrsOf (types.submodule validatorOpts);
    default = {};
    description = ''
      Specification of one or more Lighthouse validator instances.
    '';
  };
}
