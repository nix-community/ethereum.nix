{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  validatorOpts = {
    options = {
      enable = mkEnableOption "Lighthouse Validator Client";

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
          Lighthouse Validator configuration. Converted to CLI arguments.

          Use http = true for --http flag, metrics = true for --metrics flag.
          All options passed as --option-name value.

          When beacon-nodes is not set, automatically looks up the
          lighthouse beacon node with the same name.

          See https://lighthouse-book.sigmaprime.io for available options.
        '';
        example = literalExpression ''
          {
            network = "mainnet";
            beacon-nodes = ["http://127.0.0.1:5052"];
            suggested-fee-recipient = "0x...";
            graffiti = "my-validator";
            http = true;
            http-address = "127.0.0.1";
            http-port = 5062;
            metrics = true;
            metrics-address = "127.0.0.1";
            metrics-port = 5064;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Lighthouse Validator Client.";
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
    description = "Specification of one or more Lighthouse validator instances.";
  };
}
