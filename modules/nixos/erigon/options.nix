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

  erigonOpts = {
    options = {
      enable = mkEnableOption "Erigon Ethereum Node";

      package = mkOption {
        type = types.package;
        default = pkgs.erigon;
        defaultText = literalExpression "pkgs.erigon";
        description = "Package to use as Erigon node.";
      };

      subVolume = mkEnableOption "Use a subvolume for the state directory if the underlying filesystem supports it e.g. btrfs";

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services.";
      };

      service = {
        supplementaryGroups = mkOption {
          default = [ ];
          type = types.listOf types.str;
          description = "Additional groups for the systemd service e.g. sops-nix group for secret access.";
        };
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = { };
        description = ''
          Erigon configuration options. These are converted to CLI arguments.
          Use flat dotted keys that match CLI flag names (e.g., "http.addr" not nested http.addr).
        '';
        example = literalExpression ''
          {
            chain = "mainnet";
            externalcl = true;
            http = true;
            "http.addr" = "0.0.0.0";
            "http.port" = 8545;
            "http.api" = ["eth" "net" "web3"];
            "authrpc.jwtsecret" = "/var/run/erigon/jwtsecret";
            "prune.mode" = "full";
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Erigon.";
        default = [ ];
      };
    };
  };
in
{
  options.services.ethereum.erigon = mkOption {
    type = types.attrsOf (types.submodule erigonOpts);
    default = { };
    description = "Specification of one or more erigon instances.";
  };
}
