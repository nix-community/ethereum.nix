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

  heliosOpts = {
    options = {
      enable = mkEnableOption "Helios light client";

      package = mkOption {
        type = types.package;
        default = pkgs.helios;
        defaultText = literalExpression "pkgs.helios";
        description = "Package to use for the Helios binary.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open the RPC port in the firewall.";
      };

      startWhenNeeded = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to use socket activation to start Helios when a connection is
          made to the RPC port.
        '';
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
          Helios configuration options. These are converted to CLI arguments.
          Use flat dashed keys that match CLI flag names (e.g., "execution-rpc",
          "rpc-port"). The "network" key selects the subcommand: "ethereum" runs
          the `ethereum` subcommand, any other value runs `opstack --network <value>`.
        '';
        example = literalExpression ''
          {
            network = "ethereum";
            execution-rpc = "http://127.0.0.1:8545";
            consensus-rpc = "https://www.lightclientdata.org";
            rpc-bind-ip = "127.0.0.1";
            rpc-port = 8545;
            checkpoint = "0x...";
            load-external-fallback = true;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Helios.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.helios = mkOption {
    type = types.attrsOf (types.submodule heliosOpts);
    default = { };
    description = "Specification of one or more Helios light client instances.";
  };
}
