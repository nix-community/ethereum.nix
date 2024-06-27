{
  lib,
  pkgs,
  ...
}: let
  beaconOpts = with lib;
    {
      name,
      config,
      ...
    }: {
      options = {
        enable = mkEnableOption "Lighthouse Ethereum Beacon Chain Node written in Rust from Sigma Prime";

        args = import ./args.nix {inherit lib name config;};

        extraArgs = mkOption {
          type = types.listOf types.str;
          description = "Additional arguments to pass to Lighthouse Beacon Chain.";
          default = [];
        };

        package = mkOption {
          default = pkgs.lighthouse;
          defaultText = literalExpression "pkgs.lighthouse";
          type = types.package;
          description = "Package to use for Lighthouse binary";
        };

        openFirewall = mkOption {
          type = types.bool;
          default = false;
          description = "Open ports in the firewall for any enabled networking services";
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
  options.services.ethereum.lighthouse-beacon = with lib;
    mkOption {
      type = types.attrsOf (types.submodule beaconOpts);
      default = {};
      description = "Specification of one or more lighthouse beacon chain instances.";
    };
}
