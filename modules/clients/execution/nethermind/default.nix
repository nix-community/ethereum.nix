{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (builtins)
    isBool
    isList
    isNull
    toString
    ;
  inherit
    (lib)
    boolToString
    concatStringsSep
    filterAttrs
    findFirst
    flatten
    hasPrefix
    literalExpression
    mapAttrs'
    mapAttrsRecursive
    mapAttrsToList
    mdDoc
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    nameValuePair
    optionalAttrs
    optionals
    types
    zipAttrsWith
    ;

  # capture config for all configured netherminds
  eachNethermind = config.services.ethereum.nethermind;

  # submodule options
  nethermindOpts = {
    options = {
      enable = mkEnableOption (mdDoc "Nethermind Ethereum Node.");

      package = mkOption {
        type = types.package;
        default = pkgs.nethermind;
        defaultText = literalExpression "pkgs.nethermind";
        description = mdDoc "Package to use as Nethermind.";
      };

      args = {
        baseDbPath = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = mdDoc "Configures the path of the Nethermind's database folder.";
        };

        config = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "mainnet";
          description = mdDoc "Determines the configuration file of the network on which Nethermind will be running.";
        };

        configsDirectory = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = mdDoc "Changes the source directory of your configuration files.";
        };

        log = mkOption {
          type = types.enum [
            "OFF"
            "TRACE"
            "DEBUG"
            "INFO"
            "WARN"
            "ERROR"
          ];
          default = "INFO";
          description = mdDoc "Changes the logging level.";
        };

        loggerConfigSource = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = mdDoc "Changes the path of the NLog.config file.";
        };

        modules = {
          # https://docs.nethermind.io/nethermind/ethereum-client/configuration/network
          Network = {
            DiscoveryPort = mkOption {
              type = types.port;
              default = 30303;
              description = mdDoc "UDP port number for incoming discovery connections.";
            };

            P2PPort = mkOption {
              type = types.port;
              default = 30303;
              description = mdDoc "TPC/IP port number for incoming P2P connections.";
            };
          };

          # https://docs.nethermind.io/nethermind/ethereum-client/configuration/jsonrpc
          JsonRpc = {
            Enabled = mkOption {
              type = types.bool;
              default = true;
              description = mdDoc "Defines whether the JSON RPC service is enabled on node startup.";
            };

            Port = mkOption {
              type = types.port;
              default = 8545;
              description = mdDoc "Port number for JSON RPC calls.";
            };

            WebSocketsPort = mkOption {
              type = types.port;
              default = 8545;
              description = mdDoc "Port number for JSON RPC web sockets calls.";
            };

            EngineHost = mkOption {
              type = types.str;
              default = "127.0.0.1";
              description = mdDoc "Host for JSON RPC calls.";
            };

            EnginePort = mkOption {
              type = types.port;
              default = 8551;
              description = mdDoc "Port for Execution Engine calls.";
            };

            JwtSecretFile = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = mdDoc "Path to file with hex encoded secret for jwt authentication.";
              example = "/var/run/geth/jwtsecret";
            };
          };

          # https://docs.nethermind.io/nethermind/ethereum-client/configuration/healthchecks
          HealthChecks = {
            Enabled = mkOption {
              type = types.bool;
              default = true;
              description = mdDoc "If 'true' then Health Check endpoints is enabled at /health.";
            };
          };

          # https://docs.nethermind.io/nethermind/ethereum-client/configuration/metrics
          Metrics = {
            Enabled = mkOption {
              type = types.bool;
              default = true;
              description = mdDoc "If 'true',the node publishes various metrics to Prometheus Pushgateway at given interval.";
            };

            ExposePort = mkOption {
              type = types.nullOr types.port;
              default = null;
              description = mdDoc "If 'true' then Health Check endpoints is enabled at /health";
            };
          };
        };
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = mdDoc "Additional arguments to pass to Nethermind.";
        default = [];
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for any enabled networking services";
      };

      service = {
        supplementaryGroups = mkOption {
          default = [];
          type = types.listOf types.str;
          description = mdDoc "Additional groups for the systemd service e.g. sops-nix group for secret access.";
        };
      };
    };
  };
in {
  ###### interface

  options = {
    services.ethereum.nethermind = mkOption {
      type = types.attrsOf (types.submodule nethermindOpts);
      default = {};
      description = mdDoc "Specification of one or more Nethermind instances.";
    };
  };

  ###### implementation

  config = mkIf (eachNethermind != {}) {
    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachNethermind;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedUDPPorts = [modules.Network.DiscoveryPort];
              allowedTCPPorts =
                [modules.Network.P2PPort modules.JsonRpc.EnginePort]
                ++ (optionals modules.JsonRpc.Enabled [modules.JsonRpc.Port modules.JsonRpc.WebSocketsPort])
                ++ (optionals modules.Metrics.Enabled && (modules.Metrics.ExposePort != null) [modules.Metrics.ExposePort]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (name: flatten) perService;

    # create a service for each instance
    systemd.services =
      mapAttrs' (
        nethermindName: let
          serviceName = "nethermind-${nethermindName}";

          modulesLib = import ../../../lib.nix {inherit lib pkgs;};
          inherit (modulesLib) mkArgs baseServiceConfig;
        in
          cfg: let
            scriptArgs = let
              # custom arg reducer for nethermind
              argReducer = value:
                if (isList value)
                then concatStringsSep "," value
                else if (isBool value)
                then boolToString value
                else toString value;

              # remove modules from arguments
              pathReducer = path: let
                arg = concatStringsSep "." (lib.lists.remove "modules" path);
              in "--${arg}";

              # custom arg formatter for nethermind
              argFormatter = {
                opt,
                path,
                value,
                argReducer,
                pathReducer,
              }: let
                arg = pathReducer path;
              in "${arg} ${argReducer value}";

              jwtSecret =
                if cfg.args.modules.JsonRpc.JwtSecretFile != null
                then "--JsonRpc.JwtSecretFile %d/jwtsecret"
                else "";

              # generate flags
              args = mkArgs {
                inherit pathReducer argReducer argFormatter;
                inherit (cfg) args;
                opts = nethermindOpts.options.args;
              };

              # filter out certain args which need to be treated differently
              specialArgs = ["--JsonRpc.JwtSecretFile"];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;

              filteredArgs = builtins.filter isNormalArg args;
            in ''
              --datadir %S/${serviceName} \
              ${jwtSecret} \
              ${concatStringsSep " \\\n" filteredArgs} \
              ${lib.escapeShellArgs cfg.extraArgs}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Nethermind Node (${nethermindName})";

              # create service config by merging with the base config
              serviceConfig = mkMerge [
                baseServiceConfig
                {
                  User = serviceName;
                  StateDirectory = serviceName;
                  ExecStart = "${cfg.package}/bin/Nethermind.Runner ${scriptArgs}";
                }
                (mkIf (cfg.args.modules.JsonRpc.JwtSecretFile != null) {
                  LoadCredential = "jwtsecret:${cfg.args.modules.JsonRpc.JwtSecretFile}";
                })
              ];
            })
      )
      eachNethermind;
  };
}
