{
  lib,
  pkgs,
  ...
}: let
  args = import ./args.nix lib;

  web3signerOpts = with lib; {
    options = {
      enable = mkEnableOption "Web3Signer Ethereum Node.";

      package = mkOption {
        type = types.package;
        default = pkgs.web3signer;
        defaultText = literalExpression "pkgs.web3signer";
        description = "Package to use as Web3Signer.";
      };

      inherit args;

      extraGenericArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Web3Signer.";
        default = [];
      };

      extraModeArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Web3Signer.";
        default = [];
      };

      mode = mkOption {
        type = types.str;
        description = "Web3signer mode.";
        default = "eth2";
      };

      user = mkOption {
        type = types.nullOr types.str;
        description = "Service user";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services";
      };
    };
  };
in {
  options.services.ethereum.web3signer = with lib;
    mkOption {
      type = types.attrsOf (types.submodule web3signerOpts);
      default = {};
      description = "Specification of one or more Web3Signer instances.";
    };
}
