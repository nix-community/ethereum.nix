{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    literalExpression
    ;

  mevBoostOpts = {
    options = {
      enable = mkEnableOption "MEV-Boost from Flashbots";

      package = mkOption {
        default = pkgs.mev-boost;
        defaultText = literalExpression "pkgs.mev-boost";
        type = types.package;
        description = "Package to use for mev-boost binary";
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = { };
        description = ''
          MEV-Boost configuration options. These are converted to CLI arguments.
          Use flat dashed keys that match CLI flag names.
        '';
        example = literalExpression ''
          {
            holesky = true;
            addr = "localhost:18550";
            relays = [
              "https://0xafa4c6985aa049fb79dd37010438cfebeb0f2bd42b115b89dd678dab0670c1de38da0c4e9138c9290a398ecd9a0b3110@boost-relay-holesky.flashbots.net"
            ];
            relay-check = true;
            min-bid = 0.05;
            loglevel = "info";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to MEV-Boost.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.mev-boost = mkOption {
    type = types.attrsOf (types.submodule mevBoostOpts);
    default = { };
    description = "Specification of one or more MEV-Boost chain instances.";
  };
}
