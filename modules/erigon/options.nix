{
  lib,
  pkgs,
  ...
}: let
  args = import ./args.nix lib;

  erigonOpts = with lib; {
    options = {
      enable = mkEnableOption (mdDoc "Erigon Ethereum Node.");

      subVolume = mkEnableOption (mdDoc "Use a subvolume for the state directory if the underlying filesystem supports it e.g. btrfs");

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = mdDoc "Additional arguments to pass to Erigon.";
        default = [];
      };

      blst-portable = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Make blst library used by erigon build in portable mode. When this option is enabled, the package option is ignored.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.erigon;
        defaultText = literalExpression "pkgs.erigon";
        description = mdDoc "Package to use as Erigon node.";
      };

      service = {
        supplementaryGroups = mkOption {
          default = [];
          type = types.listOf types.str;
          description = mdDoc "Additional groups for the systemd service e.g. sops-nix group for secret access";
        };
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for any enabled networking services";
      };
    };
  };
in {
  options.services.ethereum.erigon = with lib;
    mkOption {
      type = types.attrsOf (types.submodule erigonOpts);
      default = {};
      description = mdDoc "Specification of one or more erigon instances.";
    };
}
