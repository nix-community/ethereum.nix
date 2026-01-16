{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  nimbusOpts = {
    options = {
      enable = mkEnableOption "Nimbus Beacon Chain Node";

      package = mkOption {
        type = types.package;
        default = pkgs.nimbus;
        defaultText = literalExpression "pkgs.nimbus";
        description = "Package to use for Nimbus binary.";
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
          Nimbus Beacon Chain configuration. Converted to CLI arguments.

          All options passed as --option-name=value.
          Use rest = true for --rest flag.

          See https://nimbus.guide for available options.
        '';
        example = literalExpression ''
          {
            network = "mainnet";
            el = ["http://127.0.0.1:8551"];
            jwt-secret = "/var/run/nimbus/jwtsecret";
            trusted-node-url = "https://checkpoint-sync.ethpandaops.io";
            rest = true;
            rest-address = "0.0.0.0";
            metrics = true;
            metrics-address = "0.0.0.0";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Nimbus Beacon Chain.";
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
  options.services.ethereum.nimbus = mkOption {
    type = types.attrsOf (types.submodule nimbusOpts);
    default = {};
    description = "Specification of one or more Nimbus Beacon Chain instances.";
  };
}
