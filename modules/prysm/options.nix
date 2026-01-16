{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  prysmOpts = {
    options = {
      enable = mkEnableOption "Prysm Beacon Chain Node";

      package = mkOption {
        type = types.package;
        default = pkgs.prysm;
        defaultText = literalExpression "pkgs.prysm";
        description = "Package to use for Prysm binary.";
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
          Prysm Beacon Chain configuration. Converted to CLI arguments.

          Use sepolia/holesky/hoodi = true for network selection.
          All options passed as --option-name value.

          See https://docs.prylabs.network for available options.
        '';
        example = literalExpression ''
          {
            sepolia = true;
            jwt-secret = "/var/run/prysm/jwtsecret";
            checkpoint-sync-url = "https://checkpoint-sync.sepolia.ethpandaops.io";
            genesis-beacon-api-url = "https://checkpoint-sync.sepolia.ethpandaops.io";
            grpc-gateway-host = "0.0.0.0";
            monitoring-host = "0.0.0.0";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Prysm Beacon Chain.";
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
  options.services.ethereum.prysm = mkOption {
    type = types.attrsOf (types.submodule prysmOpts);
    default = {};
    description = "Specification of one or more Prysm Beacon Chain instances.";
  };
}
