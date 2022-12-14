{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.lists) optionals;
  inherit (lib) mdDoc flatten nameValuePair;
  inherit (lib) zipAttrsWith filterAttrsRecursive filterAttrs mapAttrs mapAttrs' mapAttrsToList;
  inherit (lib) optionalString literalExpression mkEnableOption mkIf mkOption types concatStringsSep;

  settingsFormat = pkgs.formats.yaml {};

  eachErigon = config.services.erigon;

  erigonOpts = {
    options = {
      enable = mkEnableOption (mdDoc "Erigon Ethereum Node.");

      args = {
        datadir = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = mdDoc "Data directory for the databases.";
        };

        port = mkOption {
          type = types.port;
          default = 30303;
          description = mdDoc "Network listening port.";
        };

        snapshots = mkOption {
          type = types.bool;
          default = true;
          description = mdDoc ''
            Default: use snapshots "true" for BSC, Mainnet and Goerli. use snapshots "false" in all other cases.
          '';
        };

        externalcl = mkEnableOption (mdDoc "enables external consensus");

        chain = mkOption {
          type = types.enum [
            "mainnet"
            "rinkeby"
            "goerli"
            "sokol"
            "fermion"
            "mumbai"
            "bor-mainnet"
            "bor-devnet"
            "sepolia"
            "gnosis"
            "chiado"
          ];
          default = "mainnet";
          description = mdDoc "Name of the network to join. If null the network is mainnet.";
        };

        torrent = {
          port = mkOption {
            type = types.port;
            default = 42069;
            description = mdDoc "Port to listen and serve BitTorrent protocol .";
          };
        };

        http = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = mdDoc "Enable HTTP-RPC server";
          };

          address = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = mdDoc "HTTP-RPC server listening interface.";
          };

          port = mkOption {
            type = types.port;
            default = 8545;
            description = mdDoc "HTTP-RPC server listening port.";
          };

          compression = mkEnableOption (mdDoc "Enable compression over HTTP-RPC.");

          corsdomain = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = mdDoc "List of domains from which to accept cross origin requests.";
            example = ["*"];
          };

          vhosts = mkOption {
            type = types.listOf types.str;
            default = ["localhost"];
            description = mdDoc ''
              Comma separated list of virtual hostnames from which to accept requests (server enforced).
              Accepts '*' wildcard.
            '';
            example = ["localhost" "erigon.example.org"];
          };

          apis = mkOption {
            type = types.listOf types.str;
            default = ["eth" "erigon" "engine"];
            description = mdDoc "API's offered over the HTTP-RPC interface.";
            example = ["net" "eth"];
          };

          trace = mkEnableOption (mdDoc "Trace HTTP requests with INFO level");

          timeouts = {
            idle = mkOption {
              type = types.str;
              default = "2m0s";
              description = ''
                Maximum amount of time to wait for the next request when keep-alives are enabled. If http.timeouts.idle
                is zero, the value of http.timeouts.read is used.
              '';
              example = "30s";
            };
            read = mkOption {
              type = types.str;
              default = "30s";
              description = "Maximum duration for reading the entire request, including the body.";
              example = "30s";
            };
            write = mkOption {
              type = types.str;
              default = "30m0s";
              description = ''
                Maximum duration before timing out writes of the response. It is reset whenever a new request's
                header is read.
              '';
              example = "30m0s";
            };
          };
        };

        websocket = {
          enable = mkEnableOption (mdDoc "Erigon WebSocket API");
          compression = mkEnableOption (mdDoc "Enable compression over HTTP-RPC.");
        };

        authrpc = {
          address = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = mdDoc "HTTP-RPC server listening interface for the Engine API.";
          };

          port = mkOption {
            type = types.port;
            default = 8551;
            description = mdDoc "HTTP-RPC server listening port for the Engine API";
          };

          vhosts = mkOption {
            type = types.listOf types.str;
            default = ["localhost"];
            description = mdDoc ''
              Comma separated list of virtual hostnames from which to accept Engine API requests
              (server enforced). Accepts '*' wildcard."
            '';
            example = ["localhost" "erigon.example.org"];
          };

          jwtsecret = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = mdDoc "Path to the token that ensures safe connection between CL and EL.";
            example = "/var/run/erigon/jwtsecret";
          };

          timeouts = {
            idle = mkOption {
              type = types.str;
              default = "2m0s";
              description = ''
                Maximum amount of time to wait for the next request when keep-alives are enabled. If http.timeouts.idle
                is zero, the value of http.timeouts.read is used.
              '';
              example = "30s";
            };
            read = mkOption {
              type = types.str;
              default = "30s";
              description = "Maximum duration for reading the entire request, including the body.";
              example = "30s";
            };
            write = mkOption {
              type = types.str;
              default = "30m0s";
              description = ''
                Maximum duration before timing out writes of the response. It is reset whenever a new request's
                header is read.
              '';
              example = "30m0s";
            };
          };
        };

        private.api = {
          address = mkOption {
            type = types.str;
            default = "127.0.0.1:9090";
            description = mdDoc ''
              Private api network address, for example: 127.0.0.1:9090, empty string means not to start the listener. Do not expose to public network. Serves remote database interface.
            '';
          };
          ratelimit = mkOption {
            type = types.int;
            default = 31872;
            description = mdDoc ''
              Amount of requests server handle simultaneously - requests over this limit will wait. Increase it - if clients see 'request timeout' while server load is low - it means your 'hot data' is small or have much RAM.
            '';
          };
        };

        metrics = {
          enable = mkEnableOption (mdDoc "Enable metrics collection and reporting.");

          address = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = mdDoc "Enable stand-alone metrics HTTP server listening interface.";
          };

          port = mkOption {
            type = types.port;
            default = 6060;
            description = mdDoc "Metrics HTTP server listening port";
          };
        };
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = mdDoc "Additional arguments to pass to Erigon.";
        default = [];
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
  # Disable the service definition currently in nixpkgs
  disabledModules = ["services/blockchain/ethereum/erigon.nix"];

  ###### interface

  options = {
    services.erigon = mkOption {
      type = types.attrsOf (types.submodule erigonOpts);
      default = {};
      description = mdDoc "Specification of one or more erigon instances.";
    };
  };

  ###### implementation

  config = mkIf (eachErigon != {}) {
    # collect packages and add them to the system
    environment.systemPackages = flatten (mapAttrsToList
      (_: cfg: [
        cfg.package
      ])
      eachErigon);

    # add a group for each instance
    users.groups =
      mapAttrs'
      (erigonName: _: nameValuePair "erigon-${erigonName}" {})
      eachErigon;

    # add a system user for each instance
    users.users =
      mapAttrs'
      (erigonName: _:
        nameValuePair "erigon-${erigonName}" {
          isSystemUser = true;
          group = "erigon-${erigonName}";
          description = "System user for erigon ${erigonName} instance";
        })
      eachErigon;

    # ensure data directories are created and have the correct permissions for any instances that specify one
    systemd.tmpfiles.rules =
      lib.lists.flatten
      (mapAttrsToList
        (
          erigonName: cfg:
            lib.lists.optionals (cfg.args.datadir != null) [
              "d ${cfg.args.datadir} 0700 erigon-${erigonName} erigon-${erigonName} - -"
            ]
        )
        eachErigon);

    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachErigon;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedUDPPorts = [port torrent.port];
              allowedTCPPorts =
                [port authrpc.port torrent.port]
                ++ (optionals http.enable [http.port])
                ++ (optionals websocket.enable [websocket.port])
                ++ (optionals metrics.enable [metrics.port]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (name: vals: flatten vals) perService;

    # create a service for each instance
    systemd.services =
      mapAttrs'
      (
        erigonName: let
          stateDir = "erigon-${erigonName}";
          datadir = "/var/lib/${stateDir}";

          inherit (import ./lib.nix {inherit lib pkgs;}) script;
          inherit (script) flag arg optionalArg joinArgs;
        in
          cfg:
            nameValuePair "erigon-${erigonName}" (mkIf cfg.enable {
              description = "Erigon Ethereum node (${erigonName})";
              wantedBy = ["multi-user.target"];
              after = ["network.target"];

              unitConfig = {
                RequiresMountsFor = optionals (cfg.args.datadir != null) [
                  cfg.args.datadir
                ];
              };

              serviceConfig = {
                User = "erigon-${erigonName}";
                Group = "erigon-${erigonName}";

                Restart = "always";
                StateDirectory = stateDir;
                SupplementaryGroups = cfg.service.supplementaryGroups;

                # bind custom data dir to /var/lib/... if provided
                BindPaths = lib.lists.optionals (cfg.args.datadir != null) [
                  "${cfg.args.datadir}:${datadir}"
                ];

                # Hardening measures
                CapabilityBoundingSet = "";
                RemoveIPC = "true";
                PrivateTmp = "true";
                ProtectSystem = "full";
                ProtectHome = "read-only";
                ProtectClock = true;
                ProtectProc = "noaccess";
                ProcSubset = "pid";
                ProtectKernelLogs = true;
                ProtectKernelModules = true;
                ProtectKernelTunables = true;
                ProtectControlGroups = true;
                ProtectHostname = true;
                NoNewPrivileges = "true";
                PrivateDevices = "true";
                RestrictSUIDSGID = "true";
                RestrictRealtime = true;
                RestrictNamespaces = true;
                LockPersonality = true;
                MemoryDenyWriteExecute = "true";
                SystemCallFilter = ["@system-service" "~@privileged"];
              };

              script = with cfg.args; let
                httpArgs = optionals http.enable [
                  "--http"
                  (arg "http.addr" http.address)
                  (arg "http.port" (toString http.port))
                  (flag "http.compression" http.compression)
                  (optionalArg "http.corsdoman" (http.corsdomain != null) (concatStringsSep "," http.corsdomain))
                  (arg "http.vhosts" (concatStringsSep "," http.vhosts))
                  (optionalArg "http.api" (http.apis != null) (concatStringsSep "," http.apis))
                  (flag "http.trace" http.trace)
                  (arg "http.timeouts.read" http.timeouts.read)
                  (arg "http.timeouts.write" http.timeouts.write)
                  (arg "http.timeouts.idle" http.timeouts.idle)
                ];

                authrpcArgs = [
                  (arg "authrpc.addr" authrpc.address)
                  (arg "authrpc.port" (toString authrpc.port))
                  (arg "authrpc.vhosts" (concatStringsSep "," authrpc.vhosts))
                  (optionalArg "authrpc.jwtsecret" (authrpc.jwtsecret != null) authrpc.jwtsecret)
                  (arg "authrpc.timeouts.read" authrpc.timeouts.read)
                  (arg "authrpc.timeouts.write" authrpc.timeouts.write)
                  (arg "authrpc.timeouts.idle" authrpc.timeouts.idle)
                ];

                privateApiArgs = [
                  (arg "private.api.addr" private.api.address)
                  (arg "private.api.ratelimit" private.api.ratelimit)
                ];

                websocketArgs = optionals websocket.enable [
                  "--ws"
                  (flag "ws.compression" websocket.compression)
                ];

                metricsArgs = optionals metrics.enable [
                  "--metrics"
                  (arg "metrics.addr" metrics.address)
                  (arg "metrics.port" (toString metrics.port))
                ];
              in
                joinArgs [
                  "${cfg.package}/bin/erigon"
                  (flag "snapshots" snapshots)
                  (arg "port" port)
                  (flag "externalcl" externalcl)
                  (arg "chain" chain)
                  (arg "torrent.port" torrent.port)
                  httpArgs
                  websocketArgs
                  authrpcArgs
                  metricsArgs
                  privateApiArgs
                  (lib.escapeShellArgs cfg.extraArgs)
                  (arg "datadir" datadir)
                ];
            })
      )
      eachErigon;
  };
}
