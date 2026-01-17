{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types literalExpression;

  erigonOpts = {
    options = {
      enable = mkEnableOption "Erigon Ethereum Node";

      subVolume = mkEnableOption "Use a subvolume for the state directory if the underlying filesystem supports it e.g. btrfs";

      package = mkOption {
        type = types.package;
        default = pkgs.erigon;
        defaultText = literalExpression "pkgs.erigon";
        description = "Package to use as Erigon node.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services.";
      };

      service = {
        supplementaryGroups = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Additional groups for the systemd service e.g. sops-nix group for secret access.";
        };
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = {};
        description = ''
          Erigon configuration. Converted to CLI arguments.

          Use flat dotted keys (e.g., "http.addr" not http.addr).
          Use http = true for --http flag.
          All options passed as --option.name value.

          See https://github.com/ledgerwatch/erigon for available options.
        '';
        example = literalExpression ''
          {
            chain = "mainnet";
            port = 30303;
            http = true;
            "http.addr" = "127.0.0.1";
            "http.port" = 8545;
            "http.api" = ["eth" "net" "web3"];
            "http.vhosts" = ["localhost"];
            ws = true;
            "authrpc.addr" = "127.0.0.1";
            "authrpc.port" = 8551;
            "authrpc.jwtsecret" = "/var/run/erigon/jwtsecret";
            "torrent.port" = 42069;
            metrics = true;
            "metrics.addr" = "127.0.0.1";
            "metrics.port" = 6060;
            "prune.mode" = "full";
            externalcl = true;
          }
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments to pass to Erigon.";
      };
    };
  };
in {
  options.services.ethereum.erigon = mkOption {
    type = types.attrsOf (types.submodule erigonOpts);
    default = {};
    description = "Specification of one or more Erigon instances.";
  };
}
