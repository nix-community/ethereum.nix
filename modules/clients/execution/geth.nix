/*
* Derived from https://github.com/NixOS/nixpkgs/blob/45b92369d6fafcf9e462789e98fbc735f23b5f64/nixos/modules/services/blockchain/ethereum/geth.nix
*/
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  inherit (lib.lists) optionals findFirst;
  inherit (lib.strings) hasPrefix;
  inherit (lib.attrsets) zipAttrsWith mapAttrsRecursive optionalAttrs;
  inherit (lib) mdDoc flatten nameValuePair filterAttrs mapAttrs mapAttrs' mapAttrsToList;
  inherit (lib) optionalString literalExpression mkEnableOption mkIf mkMerge mkOption types concatStringsSep;

  # capture config for all configured geths
  eachGeth = config.services.ethereum.geth;

  # submodule options
  gethOpts = {
    options = rec {
      enable = mkEnableOption (mdDoc "Go Ethereum Node");

      args = {
        port = mkOption {
          type = types.port;
          default = 30303;
          description = mdDoc "Port number Go Ethereum will be listening on, both TCP and UDP.";
        };

        http = {
          enable = mkEnableOption (mdDoc "Go Ethereum HTTP API");

          addr = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = mdDoc "HTTP-RPC server listening interface";
          };

          port = mkOption {
            type = types.port;
            default = 8545;
            description = mdDoc "Port number of Go Ethereum HTTP API.";
          };

          api = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = mdDoc "API's offered over the HTTP-RPC interface";
            example = ["net" "eth"];
          };

          corsdomain = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = mdDoc "List of domains from which to accept cross origin requests";
            example = ["*"];
          };

          rpcprefix = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = mdDoc "HTTP path path prefix on which JSON-RPC is served. Use '/' to serve on all paths.";
            example = "/";
          };

          vhosts = mkOption {
            type = types.listOf types.str;
            default = ["localhost"];
            description = mdDoc ''
              Comma separated list of virtual hostnames from which to accept requests (server enforced).
              Accepts '*' wildcard.
            '';
            example = ["localhost" "geth.example.org"];
          };
        };

        ws = {
          enable = mkEnableOption (mdDoc "Go Ethereum WebSocket API");
          addr = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = mdDoc "Listen address of Go Ethereum WebSocket API.";
          };

          port = mkOption {
            type = types.port;
            default = 8546;
            description = mdDoc "Port number of Go Ethereum WebSocket API.";
          };

          api = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = mdDoc "APIs to enable over WebSocket";
            example = ["net" "eth"];
          };
        };

        authrpc = {
          addr = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = mdDoc "Listen address of Go Ethereum Auth RPC API.";
          };

          port = mkOption {
            type = types.port;
            default = 8551;
            description = mdDoc "Port number of Go Ethereum Auth RPC API.";
          };

          vhosts = mkOption {
            type = types.listOf types.str;
            default = ["localhost"];
            description = mdDoc "List of virtual hostnames from which to accept requests.";
            example = ["localhost" "geth.example.org"];
          };

          jwtsecret = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = mdDoc "Path to a JWT secret for authenticated RPC endpoint.";
            example = "/var/run/geth/jwtsecret";
          };
        };

        metrics = {
          enable = mkEnableOption (mdDoc "Go Ethereum prometheus metrics");
          addr = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = mdDoc "Listen address of Go Ethereum metrics service.";
          };

          port = mkOption {
            type = types.port;
            default = 6060;
            description = mdDoc "Port number of Go Ethereum metrics service.";
          };
        };

        network = mkOption {
          type = types.nullOr (types.enum ["goerli" "kiln" "rinkeby" "ropsten" "sepolia"]);
          default = null;
          description = mdDoc "The network to connect to. Mainnet (null) is the default ethereum network.";
        };

        syncmode = mkOption {
          type = types.enum ["snap" "fast" "full" "light"];
          default = "snap";
          description = mdDoc "Blockchain sync mode.";
        };

        gcmode = mkOption {
          type = types.enum ["full" "archive"];
          default = "full";
          description = mdDoc "Blockchain garbage collection mode.";
        };

        maxpeers = mkOption {
          type = types.int;
          default = 50;
          description = mdDoc "Maximum peers to connect to.";
        };
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = mdDoc "Additional arguments to pass to Go Ethereum.";
        default = [];
      };

      package = mkOption {
        type = types.package;
        default = pkgs.geth;
        defaultText = literalExpression "pkgs.geth";
        description = mdDoc "Package to use as Go Ethereum node.";
      };

      metadataPackage = mkOption {
        type = types.package;
        default = pkgs.writeShellScript "geth-metadata" ''
          set -euo pipefail
          ${pkgs.geth}/bin/geth --datadir $STATE_DIRECTORY db metadata > $STATE_DIRECTORY/metadata.txt
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for any enabled networking services";
      };
    };
  };
in {
  # Disable the service definition currently in nixpkgs
  disabledModules = ["services/blockchain/ethereum/geth.nix"];

  ###### interface

  options = {
    services.ethereum.geth = mkOption {
      type = types.attrsOf (types.submodule gethOpts);
      default = {};
      description = mdDoc "Specification of one or more geth instances.";
    };
  };

  ###### implementation

  config = mkIf (eachGeth != {}) {
    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachGeth;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedUDPPorts = [port];
              allowedTCPPorts =
                [port authrpc.port]
                ++ (optionals http.enable [http.port])
                ++ (optionals ws.enable [ws.port])
                ++ (optionals metrics.enable [metrics.port]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (name: flatten) perService;

    # create a service for each instance
    systemd.services =
      mapAttrs'
      (
        gethName: let
          serviceName = "geth-${gethName}";

          modulesLib = import ../../lib.nix {inherit lib pkgs;};
          inherit (modulesLib) mkArgs baseServiceConfig;
        in
          cfg: let
            scriptArgs = let
              # replace enable flags like --http.enable with just --http
              pathReducer = path: let
                arg = concatStringsSep "." (lib.lists.remove "enable" path);
              in "--${arg}";

              # generate flags
              args = mkArgs {
                inherit pathReducer;
                inherit (cfg) args;
                opts = gethOpts.options.args;
              };

              # filter out certain args which need to be treated differently
              specialArgs = ["--network" "--authrpc.jwtsecret"];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;

              filteredArgs = builtins.filter isNormalArg args;

              network =
                if cfg.args.network != null
                then "--${cfg.args.network}"
                else "";

              jwtSecret =
                if cfg.args.authrpc.jwtsecret != null
                then "--authrpc.jwtsecret %d/jwtsecret"
                else "";
            in ''
              --ipcdisable ${network} ${jwtSecret} \
              --datadir %S/${serviceName} \
              ${concatStringsSep " \\\n" filteredArgs} \
              ${lib.escapeShellArgs cfg.extraArgs}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Go Ethereum node (${gethName})";

              # create service config by merging with the base config
              serviceConfig = mkMerge [
                baseServiceConfig
                {
                  User = serviceName;
                  StateDirectory = serviceName;
                  ExecStart = "${cfg.package}/bin/geth ${scriptArgs}";
                  ExecStopPost = [
                    cfg.metadataPackage
                  ];
                }
                (mkIf (cfg.args.authrpc.jwtsecret != null) {
                  LoadCredential = "jwtsecret:${cfg.args.authrpc.jwtsecret}";
                })
              ];
            })
      )
      eachGeth;
  };
}
