{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  mevBoostOpts = {
    options = {
      enable = mkEnableOption "MEV-Boost from Flashbots";

      package = mkOption {
        type = types.package;
        default = pkgs.mev-boost;
        defaultText = literalExpression "pkgs.mev-boost";
        description = "Package to use for mev-boost binary.";
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = {};
        description = ''
          MEV-Boost configuration. Converted to CLI arguments.

          Use mainnet/sepolia/hoodi = true for network selection.
          All options passed as -option-name value.

          See https://github.com/flashbots/mev-boost for available options.
        '';
        example = literalExpression ''
          {
            mainnet = true;
            relays = [ "https://0xac6e77dfe25ecd6110b8e780608cce0dab71fdd5ebea22a16c0205200f2f8e2e3ad3b71d3499c54ad14d6c21b41a37ae@boost-relay.flashbots.net" ];
            addr = "0.0.0.0:18550";
            min-bid = 0.05;
            relay-check = true;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to MEV-Boost.";
      };
    };
  };
in {
  options.services.ethereum.mev-boost = mkOption {
    type = types.attrsOf (types.submodule mevBoostOpts);
    default = {};
    description = "Specification of one or more MEV-Boost instances.";
  };
}
