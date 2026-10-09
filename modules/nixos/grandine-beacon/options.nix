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
      enable = mkEnableOption "Grandine Ethereum Beacon Chain Node";

      package = mkOption {
        type = types.package;
        default = pkgs.grandine;
        defaultText = literalExpression "pkgs.grandine";
        description = "Package to use for Grandine binary.";
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
          Grandine beacon node configuration options. These are written to a
          YAML file loaded via `--args-file`. Use the long option names
          without the leading `--` (e.g. "http-port" not "http.port").

          Refer to `grandine --help` for the full list of supported options.
        '';
        example = literalExpression ''
          {
            network = "sepolia";
            checkpoint-sync-url = "https://checkpoint-sync.sepolia.ethpandaops.io";
            libp2p-port = 9000;
            discovery-port = 9000;
            http-address = "0.0.0.0";
            http-port = 5052;
            metrics = true;
            metrics-address = "127.0.0.1";
            metrics-port = 5054;
            eth1-rpc-urls = [ "http://127.0.0.1:8551" ];
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Grandine.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.grandine-beacon = mkOption {
    type = types.attrsOf (types.submodule beaconOpts);
    default = { };
    description = "Specification of one or more Grandine beacon node instances.";
  };
}
