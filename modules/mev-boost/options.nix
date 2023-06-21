{
  lib,
  pkgs,
  ...
}:
with lib; let
  args = import ./args.nix lib;

  mevBoostOpts = {
    options = {
      enable = mkEnableOption "MEV-Boost from Flashbots.";

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to MEV-Boost.";
        default = [];
      };

      package = mkOption {
        default = pkgs.mev-boost;
        defaultText = literalExpression "pkgs.mev-boost";
        type = types.package;
        description = "Package to use for mev-boost binary.";
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
  options.services.ethereum.mev-boost = mkOption {
    type = with types; attrsOf (submodule mevBoostOpts);
    default = {};
    description = "Specification of one or more MEV-Boost chain instances.";
  };
}
