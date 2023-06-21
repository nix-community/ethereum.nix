{
  lib,
  pkgs,
  ...
}:
with lib; let
  args = import ./args.nix lib;

  nethermindOpts = {
    options = {
      enable = mkEnableOption "Nethermind Ethereum Node.";

      package = mkOption {
        type = types.package;
        default = pkgs.nethermind;
        defaultText = literalExpression "pkgs.nethermind";
        description = "Package to use as Nethermind.";
      };

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Nethermind.";
        default = [];
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services.";
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
  options.services.ethereum.nethermind = mkOption {
    type = with types; attrsOf (submodule nethermindOpts);
    default = {};
    description = "Specification of one or more Nethermind instances.";
  };
}
