{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  tekuOpts = {
    options = {
      enable = mkEnableOption "Teku Ethereum Consensus Client";

      package = mkOption {
        type = types.package;
        default = pkgs.teku;
        defaultText = literalExpression "pkgs.teku";
        description = "Package to use for Teku binary.";
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
          Teku configuration. Converted to CLI arguments.

          All options passed as --option-name=value.
          Use rest-api-enabled = true for --rest-api-enabled.

          See https://docs.teku.consensys.io for available options.
        '';
        example = literalExpression ''
          {
            network = "mainnet";
            ee-endpoint = "http://127.0.0.1:8551";
            ee-jwt-secret-file = "/var/run/teku/jwtsecret";
            p2p-port = 9000;
            rest-api-enabled = true;
            rest-api-interface = "0.0.0.0";
            metrics-enabled = true;
            metrics-interface = "0.0.0.0";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Teku.";
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
  options.services.ethereum.teku = mkOption {
    type = types.attrsOf (types.submodule tekuOpts);
    default = {};
    description = "Specification of one or more Teku instances.";
  };
}
