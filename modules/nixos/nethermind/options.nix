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

  nethermindOpts = {
    options = {
      enable = mkEnableOption "Nethermind Ethereum Node";

      package = mkOption {
        type = types.package;
        default = pkgs.nethermind;
        defaultText = literalExpression "pkgs.nethermind";
        description = "Package to use as Nethermind.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services.";
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = { };
        description = ''
          Nethermind configuration options. These are converted to CLI arguments.
          Use flat dotted keys with PascalCase that match CLI flag names
          (e.g., "JsonRpc.Enabled", "Network.DiscoveryPort").
        '';
        example = literalExpression ''
          {
            config = "mainnet";
            log = "INFO";
            "JsonRpc.Enabled" = true;
            "JsonRpc.Host" = "127.0.0.1";
            "JsonRpc.Port" = 8545;
            "JsonRpc.EngineHost" = "127.0.0.1";
            "JsonRpc.EnginePort" = 8551;
            "JsonRpc.JwtSecretFile" = "/var/run/nethermind/jwtsecret";
            "Network.DiscoveryPort" = 30303;
            "Network.P2PPort" = 30303;
            "HealthChecks.Enabled" = true;
            "Metrics.Enabled" = true;
            "Metrics.ExposePort" = 9091;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Nethermind.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.nethermind = mkOption {
    type = types.attrsOf (types.submodule nethermindOpts);
    default = { };
    description = "Specification of one or more Nethermind instances.";
  };
}
