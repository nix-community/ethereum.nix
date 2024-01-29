{
  lib,
  ethereum-nix,
  ...
}: let
  args = import ./args.nix lib;

  nethermindOpts = with lib; {
    options = {
      enable = mkEnableOption (mdDoc "Nethermind Ethereum Node.");

      package = mkOption {
        type = types.package;
        default = ethereum-nix.nethermind;
        defaultText = literalExpression "pkgs.nethermind";
        description = mdDoc "Package to use as Nethermind.";
      };

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = mdDoc "Additional arguments to pass to Nethermind.";
        default = [];
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for any enabled networking services";
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
  options.services.ethereum.nethermind = with lib;
    mkOption {
      type = types.attrsOf (types.submodule nethermindOpts);
      default = {};
      description = mdDoc "Specification of one or more Nethermind instances.";
    };
}
