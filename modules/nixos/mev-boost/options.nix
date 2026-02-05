{
  lib,
  pkgs,
  ...
}:
let
  args = import ./args.nix lib;

  mevBoostOpts = with lib; {
    options = {
      enable = mkEnableOption "MEV-Boost from Flashbots";

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to MEV-Boost.";
        default = [ ];
      };

      package = mkOption {
        default = pkgs.mev-boost;
        defaultText = literalExpression "pkgs.mev-boost";
        type = types.package;
        description = "Package to use for mev-boost binary";
      };
    };
  };
in
{
  options.services.ethereum.mev-boost =
    with lib;
    mkOption {
      type = types.attrsOf (types.submodule mevBoostOpts);
      default = { };
      description = "Specification of one or more MEV-Boost chain instances.";
    };
}
