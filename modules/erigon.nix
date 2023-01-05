{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.lists) optionals;
  inherit (lib.attrsets) zipAttrsWith;
  inherit (lib) mdDoc flatten nameValuePair filterAttrs mapAttrs mapAttrs' mapAttrsToList;
  inherit (lib) optionalString literalExpression mkEnableOption mkIf mkOption types concatStringsSep;

  eachErigon = config.services.erigon;

  erigonOpts = {
    options = {
      enable = mkEnableOption (mdDoc "Erigon Ethereum Node.");

      dataDir = mkOption {
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

      http = {
        enable = mkEnableOption (mdDoc "Go Ethereum HTTP API.");

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

        apis = mkOption {
          type = types.listOf types.str;
          default = ["eth" "erigon" "engine"];
          description = mdDoc "API's offered over the HTTP-RPC interface.";
          example = ["net" "eth"];
        };

        corsdomain = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
          description = mdDoc "List of domains from which to accept cross origin requests.";
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
          example = ["localhost" "erigon.example.org"];
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
            default = "2m0s";
            description = "Maximum duration for reading the entire request, including the body.";
            example = "30s";
          };
          write = mkOption {
            type = types.str;
            default = "2m0s";
            description = ''
              Maximum duration before timing out writes of the response. It is reset whenever a new request's
              header is read.
            '';
            example = "30m0s";
          };
        };
      };

      websocket = {
        enable = mkEnableOption (mdDoc "Go Ethereum WebSocket API");
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
          type = types.str;
          default = "";
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
            default = "2m0s";
            description = "Maximum duration for reading the entire request, including the body.";
            example = "30s";
          };
          write = mkOption {
            type = types.str;
            default = "2m0s";
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

      torrent = {
        port = mkOption {
          type = types.port;
          default = 42069;
          description = mdDoc "Port to listen and serve BitTorrent protocol";
        };
      };

      chain = mkOption {
        type = types.nullOr (types.enum [
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
        ]);
        default = null;
        description = mdDoc "Name of the network to join. If null the network is mainnet.";
      };

      networkid = mkOption {
        type = types.nullOr types.int;
        default = 1;
        description = mdDoc "Explicitly set network id (integer)(For testnets: use --chain <testnet_name> instead)";
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = mdDoc "Additional arguments to pass to Go Ethereum.";
        default = [];
      };

      package = mkOption {
        type = types.package;
        default = pkgs.erigon;
        defaultText = literalExpression "pkgs.erigon";
        description = mdDoc "Package to use as Go Ethereum node.";
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
            lib.lists.optionals (cfg.dataDir != null) [
              "d ${cfg.dataDir} 0700 erigon-${erigonName} erigon-${erigonName} - -"
            ]
        )
        eachErigon);

    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachErigon;
      perService =
        mapAttrsToList
        (
          _: cfg: {
            allowedUDPPorts = [cfg.port cfg.torrent.port];
            allowedTCPPorts =
              [cfg.port cfg.authrpc.port cfg.torrent.port]
              ++ (optionals cfg.http.enable [cfg.http.port])
              ++ (optionals cfg.websocket.enable [cfg.websocket.port])
              ++ (optionals cfg.metrics.enable [cfg.metrics.port]);
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
          dataDir = "/var/lib/${stateDir}";

          inherit (import ./lib.nix lib) script;
          inherit (script) flag arg optionalArg joinArgs;
        in
          cfg:
            nameValuePair "erigon-${erigonName}" (mkIf cfg.enable {
              description = "Erigon Ethereum node (${erigonName})";
              wantedBy = ["multi-user.target"];
              after = ["network.target"];

              unitConfig = {
                RequiresMountsFor = optionals (cfg.dataDir != null) [
                  cfg.dataDir
                ];
              };

              serviceConfig = {
                User = "erigon-${erigonName}";
                Group = "erigon-${erigonName}";

                Restart = "always";
                StateDirectory = stateDir;
                SupplementaryGroups = cfg.service.supplementaryGroups;

                # bind custom data dir to /var/lib/... if provided
                BindPaths = lib.lists.optionals (cfg.dataDir != null) [
                  "${cfg.dataDir}:${dataDir}"
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

              script = with cfg; let
                httpArgs = optionals http.enable [
                  "--http"
                  (arg "http.addr" http.address)
                  (arg "http.port" (toString http.port))
                  (arg "http.compression" http.compression)
                  (arg "http.vhosts" (concatStringsSep "," http.vhosts))
                  (arg "http.trace" http.trace)
                  (arg "http.api" (concatStringsSep "," http.apis))
                  (arg "http.timeouts.idle" http.timeouts.idle)
                  (arg "http.timeouts.read" http.timeouts.read)
                  (arg "http.timeouts.write" http.timeouts.write)
                ];

                websocketArgs = optionals websocket.enable [
                  "--ws"
                  (arg "ws.compression" http.compression)
                ];

                authrpcArgs = [
                  (arg "authrpc.addr" authrpc.address)
                  (arg "authrpc.port" (toString authrpc.port))
                  (arg "authrpc.vhosts" (concatStringsSep "," authrpc.vhosts))
                  (arg "authrpc.timeouts.idle" authrpc.timeouts.idle)
                  (arg "authrpc.timeouts.read" authrpc.timeouts.read)
                  (arg "authrpc.timeouts.write" authrpc.timeouts.write)
                  (arg "authrpc.jwtsecret"
                    (
                      if (authrpc.jwtsecret != "")
                      then authrpc.jwtsecret
                      else "${stateDir}/jwtsecret"
                    ))
                ];

                privateApiArgs = [
                  (arg "private.api.addr" private.api.address)
                  (arg "private.api.ratelimit" private.api.ratelimit)
                ];

                metricsArgs = optionals metrics.enable [
                  "--metrics"
                  (arg "metrics.addr" metrics.address)
                  (arg "metrics.port" (toString metrics.port))
                ];
              in
                joinArgs [
                  "${cfg.package}/bin/erigon"
                  (arg "port" port)
                  (flag "snapshots" snapshots)
                  (flag "externalcl" externalcl)
                  (arg "torrent.port" torrent.port)
                  (optionalArg "chain" (chain != null) chain)
                  (optionalArg "networkid" (networkid != null) networkid)
                  httpArgs
                  websocketArgs
                  authrpcArgs
                  privateApiArgs
                  metricsArgs
                  (lib.escapeShellArgs extraArgs)
                  (arg "datadir" dataDir)
                ];
            })
      )
      eachErigon;
  };
}
