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
        enable = mkEnableOption "Teku is an open-source Ethereum consensus client";

        args = import ./args.nix {inherit lib name config;};

        extraArgs = mkOption {
          type = types.listOf types.str;
          description = "Additional arguments to pass to Teku Beacon Chain.";
          default = [];
        };

        package = mkOption {
          default = pkgs.teku;
          defaultText = literalExpression "pkgs.teku";
          type = types.package;
          description = "Package to use for Teku binary";
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
  options.services.ethereum.teku-beacon = with lib;
    mkOption {
      type = types.attrsOf (types.submodule beaconOpts);
      default = {};
      description = "Specification of one or more Teku beacon chain instances.";
    };
}
