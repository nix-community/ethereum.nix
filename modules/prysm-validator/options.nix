{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  validatorOpts = {
    options = {
      enable = mkEnableOption "Prysm Validator Client";

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
          Prysm Validator configuration. Converted to CLI arguments.

          Use network = "holesky" for --holesky flag (null = mainnet).
          Use rpc = true for --rpc flag.
          All options passed as --option-name value.

          See https://docs.prylabs.network for available options.
        '';
        example = literalExpression ''
          {
            network = "holesky";
            wallet-dir = "/var/lib/prysm/wallet";
            wallet-password-file = "/run/secrets/wallet-password";
            suggested-fee-recipient = "0x...";
            graffiti = "my-validator";
            grpc-gateway-host = "127.0.0.1";
            grpc-gateway-port = 7500;
            rpc = true;
            rpc-host = "127.0.0.1";
            rpc-port = 7000;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Prysm Validator.";
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
  options.services.ethereum.prysm-validator = mkOption {
    type = types.attrsOf (types.submodule validatorOpts);
    default = {};
    description = "Specification of one or more Prysm validator instances.";
  };
}
