{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

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
        default = {};
        description = ''
          Nethermind configuration. Converted to CLI arguments.

          Use flat dotted keys (e.g., "JsonRpc.Enabled" not JsonRpc.Enabled).
          All options passed as --Option.Name value.

          See https://docs.nethermind.io for available options.
        '';
        example = literalExpression ''
          {
            config = "mainnet";
            "JsonRpc.Enabled" = true;
            "JsonRpc.Host" = "127.0.0.1";
            "JsonRpc.Port" = 8545;
            "JsonRpc.EnginePort" = 8551;
            "JsonRpc.JwtSecretFile" = "/var/run/nethermind/jwtsecret";
            "Network.DiscoveryPort" = 30303;
            "Network.P2PPort" = 30303;
            "Metrics.Enabled" = true;
            "Metrics.ExposePort" = 9091;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Nethermind.";
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
    type = types.attrsOf (types.submodule nethermindOpts);
    default = {};
    description = "Specification of one or more Nethermind instances.";
  };
}
