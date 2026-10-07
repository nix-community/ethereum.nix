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

  beaconOpts = {
    options = {
      enable = mkEnableOption "Lodestar Ethereum Beacon Chain Node";

      package = mkOption {
        type = types.package;
        default = pkgs.lodestar;
        defaultText = literalExpression "pkgs.lodestar";
        description = "Package to use for Lodestar binary.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services.";
      };

      user = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "User to run the systemd service.";
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = { };
        description = ''
          Lodestar beacon node configuration options, written to a YAML file
          and passed via `--rcConfig`. Write clean nested attrsets (e.g.
          `rest.address`) — they are automatically flattened to Lodestar's
          dot-notation config keys. A nested `enable` leaf is serialised as
          the group name itself (e.g. `metrics.enable = true` becomes
          `metrics: true`), matching Lodestar's own convention.

          Refer to
          <https://chainsafe.github.io/lodestar/run/beacon-management/beacon-cli/>
          for the full list of supported options.
        '';
        example = literalExpression ''
          {
            network = "sepolia";
            execution.urls = [ "http://127.0.0.1:8551" ];
            rest = {
              enable = true;
              address = "0.0.0.0";
            };
            metrics.enable = true;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Lodestar.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.lodestar-beacon = mkOption {
    type = types.attrsOf (types.submodule beaconOpts);
    default = { };
    description = "Specification of one or more Lodestar beacon node instances.";
  };
}
