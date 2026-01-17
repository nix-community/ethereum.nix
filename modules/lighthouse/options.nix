{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  lighthouseOpts = {
    options = {
      enable = mkEnableOption "Lighthouse Beacon Chain Node";

      package = mkOption {
        type = types.package;
        default = pkgs.lighthouse;
        defaultText = literalExpression "pkgs.lighthouse";
        description = "Package to use for Lighthouse binary.";
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
          Lighthouse Beacon Chain configuration. Converted to CLI arguments.

          Use mainnet/sepolia/holesky/hoodi = true for network selection.
          All options passed as --option-name value.

          See https://lighthouse-book.sigmaprime.io for available options.
        '';
        example = literalExpression ''
          {
            mainnet = true;
            execution-endpoint = "http://127.0.0.1:8551";
            execution-jwt = "/var/run/lighthouse/jwtsecret";
            checkpoint-sync-url = "https://checkpoint-sync.ethpandaops.io";
            http = true;
            http-address = "0.0.0.0";
            metrics = true;
            metrics-address = "0.0.0.0";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Lighthouse Beacon Chain.";
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
  options.services.ethereum.lighthouse = mkOption {
    type = types.attrsOf (types.submodule lighthouseOpts);
    default = {};
    description = "Specification of one or more Lighthouse Beacon Chain instances.";
  };
}
